class_name ChainedSinner
extends CharacterBody2D

# ==============================================================================
# ⛓️ KẺ CHỊU TỘI BỊ XÍCH (THE CHAINED SINNER) - QUÁI VẬT CƠ BẢN
# ------------------------------------------------------------------------------
# HƯỚNG DẪN DÀNH CHO BẠN:
# Bấm vào Node "ChainedSinner" trong cây Scene, nhìn sang cột Inspector bên phải,
# bạn sẽ thấy toàn bộ các chỉ số dưới đây để chỉnh sửa độ khó mà không cần đụng code:
# - Máu tối đa (max_health)
# - Tốc độ chạy (move_speed)
# - Sát thương vung xích (attack_damage)
# - Khoảng cách phát hiện người chơi (detection_range)
# - Thời gian choáng khi đầy 100 Sin (stagger_duration)
# ==============================================================================

@export_group("Chỉ Số Sinh Mệnh & Tội Lỗi")
@export var max_health: int = 80             # Máu tối đa của quái
@export var max_sin: int = 100               # Mốc Sin tối đa để kích hoạt Choáng & Trừng Phạt
@export var move_speed: float = 75.0         # Tốc độ di chuyển
@export var gravity: float = 1100.0          # Trọng lực

@export_group("Tấn Công (Combat AI)")
@export var attack_damage: int = 14          # Sát thương mỗi cú quất xích
@export var attack_range: float = 65.0       # Tầm đánh (khoảng cách tới Hiệp Sĩ)
@export var detection_range: float = 260.0   # Tầm phát hiện để đuổi theo
@export var attack_windup_time: float = 0.45 # Thời gian giơ xích chuẩn bị đánh (Báo hiệu để né)
@export var attack_cooldown: float = 2.0     # Thời gian chờ giữa 2 lần ra đòn

@export_group("Cơ Chế Choáng & Trừng Phạt (Verdict)")
@export var stagger_duration: float = 2.5    # Thời gian bị choáng liệt khi chạm mốc 100 Sin
@export var verdict_damage_taken: int = 140  # Sát thương nhận vào khi Hiệp Sĩ bấm E Trừng Phạt

# --- CÁC TRẠNG THÁI CỦA QUÁI VẬT (State Machine) ---
enum State {
	PATROL,        # Đang đi tuần qua lại
	CHASE,         # Phát hiện Hiệp Sĩ -> Đuổi theo
	ATTACK_WINDUP, # Giơ xích lên cao (báo hiệu đỏ)
	ATTACK_SWING,  # Quất xích xuống (gây sát thương)
	ATTACK_RECOVER,# Khựng sau khi đánh
	STAGGER,       # Bị CHOÁNG do đầy 100 Sin
	HURT,          # Giật lùi khi bị Hiệp Sĩ chém
	DEAD           # Chết và tan biến
}

var current_state: State = State.PATROL

# Biến số gameplay
var current_health: int = 80
var current_sin: int = 0
var is_verdict_ready: bool = false   # Khi đạt 100 Sin, cờ này BẬT cho đến khi bị bấm E
var facing_direction: float = -1.0   # -1.0 nhìn trái, 1.0 nhìn phải
var start_x: float = 0.0
var patrol_distance: float = 140.0

# Bộ đếm thời gian
var state_timer: float = 0.0
var attack_cd_timer: float = 0.0
var player_ref: PlayerKnight = null

# Các Node con
@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var attack_hitbox: Hitbox = $AttackPivot/AttackHitbox
@onready var attack_pivot: Node2D = $AttackPivot
@onready var chain_arc: Line2D = $AttackPivot/ChainArc
@onready var hp_bar: ProgressBar = $OverheadUI/HpBar
@onready var sin_bar: ProgressBar = $OverheadUI/SinBar
@onready var verdict_prompt: Label = $OverheadUI/VerdictPrompt
@onready var state_label: Label = $OverheadUI/StateLabel

func _ready() -> void:
	current_health = max_health
	current_sin = 0
	start_x = global_position.x
	
	# Cấu hình Hurtbox (nhận sát thương từ kiếm của Player)
	hurtbox.hurtbox_type = Hurtbox.HurtboxType.ENEMY_OR_PROP
	hurtbox.hit_received.connect(_on_hurtbox_hit_received)
	
	# Cấu hình Hitbox vung xích (gây sát thương cho Player)
	attack_hitbox.hitbox_type = Hitbox.HitboxType.ENEMY
	attack_hitbox.damage = attack_damage
	attack_hitbox.sin_inflict = 0
	attack_hitbox.source_attacker = self
	attack_hitbox.monitoring = false
	attack_hitbox.monitorable = false
	
	if chain_arc:
		chain_arc.visible = false
	if verdict_prompt:
		verdict_prompt.visible = false
		
	_update_ui()
	_update_overhead_info()

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return
		
	# Áp dụng trọng lực
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if attack_cd_timer > 0.0:
		attack_cd_timer -= delta
		
	_find_player()
	
	# Xử lý hành vi theo từng trạng thái
	match current_state:
		State.PATROL:
			_process_patrol(delta)
		State.CHASE:
			_process_chase(delta)
		State.ATTACK_WINDUP:
			_process_attack_windup(delta)
		State.ATTACK_SWING:
			_process_attack_swing(delta)
		State.ATTACK_RECOVER:
			_process_attack_recover(delta)
		State.STAGGER:
			_process_stagger(delta)
		State.HURT:
			_process_hurt(delta)

	move_and_slide()
	_update_overhead_info()

# ==================== 1. TÌM KIẾM NGƯỜI CHƠI ====================

func _find_player() -> void:
	if player_ref and is_instance_valid(player_ref):
		return
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0] as PlayerKnight
	else:
		# Tìm trực tiếp nếu chưa gán group
		player_ref = get_tree().root.find_child("PlayerKnight", true, false) as PlayerKnight

# ==================== 2. DI CHUYỂN TUẦN TRA & TRUY ĐUỔI ====================

func _process_patrol(delta: float) -> void:
	# Nếu thấy người chơi trong tầm phát hiện -> Chuyển sang đuổi theo
	if player_ref and is_instance_valid(player_ref):
		var dist_to_player = global_position.distance_to(player_ref.global_position)
		if dist_to_player <= detection_range:
			current_state = State.CHASE
			return
			
	# Đi qua lại quanh vị trí xuất phát
	velocity.x = facing_direction * (move_speed * 0.6)
	if abs(global_position.x - start_x) > patrol_distance:
		_set_facing(-facing_direction)

func _process_chase(delta: float) -> void:
	if not player_ref or not is_instance_valid(player_ref):
		current_state = State.PATROL
		return
		
	var dist_x = player_ref.global_position.x - global_position.x
	var dist = abs(dist_x)
	
	# Quá xa thì quay lại tuần tra
	if dist > detection_range * 1.5:
		current_state = State.PATROL
		return
		
	# Quay mặt về hướng người chơi
	_set_facing(sign(dist_x))
	
	# Nếu đủ gần tầm đánh và đã hết hồi chiêu -> Tấn công!
	if dist <= attack_range and attack_cd_timer <= 0.0:
		_start_attack()
		return
		
	# Di chuyển tiếp cận người chơi
	velocity.x = facing_direction * move_speed

func _set_facing(dir: float) -> void:
	if dir == 0.0:
		return
	facing_direction = sign(dir)
	sprite.flip_h = (facing_direction > 0.0) # Ảnh gốc hướng sang trái, nên quay phải thì flip_h
	attack_pivot.scale.x = -facing_direction

# ==================== 3. HÀNH VI TẤN CÔNG (QUẤT XÍCH) ====================

func _start_attack() -> void:
	current_state = State.ATTACK_WINDUP
	state_timer = attack_windup_time
	velocity.x = 0.0
	
	# Báo hiệu nhấp nháy đỏ chuẩn bị quất xích
	var t = create_tween()
	t.tween_property(sprite, "modulate", Color(2.5, 0.4, 0.4), attack_windup_time * 0.7)
	t.tween_property(sprite, "modulate", Color.WHITE, attack_windup_time * 0.3)

func _process_attack_windup(delta: float) -> void:
	velocity.x = 0.0
	state_timer -= delta
	if state_timer <= 0.0:
		_execute_swing()

func _execute_swing() -> void:
	current_state = State.ATTACK_SWING
	state_timer = 0.22
	
	# Lao tới trước 1 bước ngắn
	velocity.x = facing_direction * 110.0
	
	# Bật Hitbox gây sát thương
	attack_hitbox.monitoring = true
	attack_hitbox.monitorable = true
	
	# Vẽ sợi xích quất ra
	if chain_arc:
		chain_arc.visible = true
		chain_arc.default_color = Color(2.0, 1.4, 0.6)
		chain_arc.width = 7.0
		chain_arc.points = PackedVector2Array([
			Vector2(-10, -50),
			Vector2(-50, -60),
			Vector2(-95, -40),
			Vector2(-70, -10)
		])
		var t = create_tween()
		t.tween_property(chain_arc, "width", 0.0, 0.2)
		t.tween_callback(func(): chain_arc.visible = false)

func _process_attack_swing(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
	state_timer -= delta
	if state_timer <= 0.0:
		attack_hitbox.monitoring = false
		attack_hitbox.monitorable = false
		current_state = State.ATTACK_RECOVER
		state_timer = 0.55
		attack_cd_timer = attack_cooldown

func _process_attack_recover(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
	state_timer -= delta
	if state_timer <= 0.0:
		current_state = State.CHASE

# ==================== 4. NHẬN SÁT THƯƠNG & TÍCH LŨY SIN ====================

func _on_hurtbox_hit_received(incoming_hitbox: Hitbox) -> void:
	if current_state == State.DEAD:
		return
		
	var dmg = incoming_hitbox.damage
	var sin_gain = incoming_hitbox.sin_inflict
	
	current_health = max(0, current_health - dmg)
	
	# Tích điểm tội lỗi Sin
	if current_sin < max_sin:
		current_sin = min(max_sin, current_sin + sin_gain)
		
	_update_ui()
	
	# Hiệu ứng nảy lùi và chớp trắng khi bị chém
	var t = create_tween()
	sprite.modulate = Color(3.0, 3.0, 3.0)
	t.tween_property(sprite, "modulate", Color.WHITE, 0.12)
	
	var push_dir = -facing_direction
	if incoming_hitbox.source_attacker:
		push_dir = sign(global_position.x - incoming_hitbox.source_attacker.global_position.x)
	velocity = Vector2(push_dir * incoming_hitbox.knockback_force, -120.0)
	
	# Kiểm tra chết
	if current_health <= 0:
		_die()
		return
		
	# KIỂM TRA ĐẠT 100 SIN -> KÍCH HOẠT CHOÁNG & TRỪNG PHẠT
	if current_sin >= max_sin and not is_verdict_ready:
		_trigger_stagger()
	elif current_state != State.STAGGER and current_state != State.ATTACK_WINDUP:
		current_state = State.HURT
		state_timer = 0.18

func _process_hurt(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
	state_timer -= delta
	if state_timer <= 0.0:
		current_state = State.CHASE

# ==================== 5. CƠ CHẾ CHOÁNG (STAGGER) & TRỪNG PHẠT (VERDICT) ====================

func _trigger_stagger() -> void:
	current_state = State.STAGGER
	is_verdict_ready = true
	state_timer = stagger_duration
	velocity = Vector2.ZERO
	
	# Tắt mọi đòn đánh đang diễn ra
	attack_hitbox.monitoring = false
	attack_hitbox.monitorable = false
	if chain_arc:
		chain_arc.visible = false
		
	# Hiện biểu tượng [E] TRỪNG PHẠT!
	if verdict_prompt:
		verdict_prompt.visible = true
		_pulse_verdict_prompt()
		
	# Hiệu ứng lắc lư choáng váng
	var wobble = create_tween().set_loops(int(stagger_duration * 4))
	wobble.tween_property(sprite, "rotation_degrees", 8.0, 0.12)
	wobble.tween_property(sprite, "rotation_degrees", -8.0, 0.12)
	wobble.tween_property(sprite, "rotation_degrees", 0.0, 0.05)

func _process_stagger(delta: float) -> void:
	velocity.x = 0.0
	state_timer -= delta
	
	# Khi hết 2.5s Choáng:
	# Quái tỉnh dậy và có thể đi lại/tấn công bình thường,
	# NHƯNG Sin vẫn giữ nguyên 100/100 và is_verdict_ready vẫn TRUE!
	if state_timer <= 0.0:
		current_state = State.CHASE
		sprite.rotation_degrees = 0.0
		# Ghi chú: Không tắt verdict_prompt vì người chơi vẫn có quyền bấm E bất cứ lúc nào!

func _pulse_verdict_prompt() -> void:
	if not verdict_prompt or not is_verdict_ready:
		return
	var t = create_tween().set_loops()
	t.tween_property(verdict_prompt, "modulate", Color(2.5, 2.2, 0.5, 1.0), 0.35)
	t.tween_property(verdict_prompt, "modulate", Color(1.0, 0.4, 0.4, 0.7), 0.35)

# Hàm này được gọi khi Hiệp Sĩ lại gần và bấm phím [E]
func receive_verdict(damage: int) -> void:
	if not is_verdict_ready:
		return
		
	# Nhận sát thương chí mạng
	current_health = max(0, current_health - damage)
	
	# RESET SIN VỀ 0 & TẮT TRẠNG THÁI TRỪNG PHẠT
	current_sin = 0
	is_verdict_ready = false
	if verdict_prompt:
		verdict_prompt.visible = false
	sprite.rotation_degrees = 0.0
	
	_update_ui()
	
	# Hiệu ứng nổ sát thương đỏ rực
	var t = create_tween()
	sprite.modulate = Color(4.0, 0.2, 0.2)
	t.tween_property(sprite, "modulate", Color.WHITE, 0.25)
	
	if current_health <= 0:
		_die()
	else:
		current_state = State.HURT
		state_timer = 0.3
		velocity = Vector2(-facing_direction * 220.0, -180.0)

# ==================== 6. CHẾT & HIỆU ỨNG GIAO DIỆN TRÊN ĐẦU ====================

func _die() -> void:
	current_state = State.DEAD
	velocity = Vector2.ZERO
	is_verdict_ready = false
	
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	attack_hitbox.set_deferred("monitoring", false)
	attack_hitbox.set_deferred("monitorable", false)
	
	if verdict_prompt:
		verdict_prompt.visible = false
	if state_label:
		state_label.text = "💀 ĐÃ BỊ KẾT LIỄU"
		
	var t = create_tween()
	t.tween_property(sprite, "modulate:a", 0.0, 0.6)
	t.tween_property(self, "scale", Vector2(1.2, 0.1), 0.4)
	t.tween_callback(queue_free)

func _update_ui() -> void:
	if hp_bar:
		hp_bar.max_value = max_health
		hp_bar.value = current_health
	if sin_bar:
		sin_bar.max_value = max_sin
		sin_bar.value = current_sin

func _update_overhead_info() -> void:
	if not state_label:
		return
	if is_verdict_ready:
		state_label.text = "⚠️ [CHOÁNG TỘI - SẴN SÀNG TRỪNG PHẠT!]"
		state_label.modulate = Color(1.0, 0.85, 0.2)
	elif current_state == State.STAGGER:
		state_label.text = "⚡ ĐANG CHOÁNG (%.1fs)" % max(0.0, state_timer)
		state_label.modulate = Color(0.9, 0.8, 0.3)
	elif current_state == State.ATTACK_WINDUP:
		state_label.text = "⚠️ SẮP QUẤT XÍCH!"
		state_label.modulate = Color(1.0, 0.3, 0.3)
	elif current_state == State.CHASE:
		state_label.text = "🔥 ĐANG TRUY ĐUỔI"
		state_label.modulate = Color(0.9, 0.6, 0.6)
	else:
		state_label.text = "👣 ĐI TUẦN"
		state_label.modulate = Color(0.7, 0.7, 0.7)
