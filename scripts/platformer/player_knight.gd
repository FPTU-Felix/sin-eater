class_name PlayerKnight
extends CharacterBody2D

# ==============================================================================
# 🎮 BỘ ĐIỀU KHIỂN HIỆP SĨ KHỔ HẠNH (PLAYER CONTROLLER)
# Bạn có thể tự do bấm vào Node Hiệp Sĩ trong Godot và chỉnh sửa các con số
# ở bảng Inspector bên phải mà không cần phải chạm vào code!
# ==============================================================================

# --- CÁC THÔNG SỐ DI CHUYỂN (Tùy chỉnh trong Inspector) ---
@export_group("Di Chuyển & Nhảy")
@export var move_speed: float = 260.0          # Tốc độ chạy của Hiệp Sĩ
@export var acceleration: float = 1600.0       # Độ nhạy tăng tốc khi bấm phím
@export var friction: float = 1800.0           # Độ bám dừng lại khi thả phím
@export var jump_velocity: float = -440.0      # Lực nhảy lên cao
@export var gravity: float = 1100.0            # Trọng lực thông thường
@export var fall_gravity_mult: float = 1.35    # Tăng trọng lực lúc rơi (giúp nhảy dứt khoát)

@export_group("Lướt Né Đòn (Dash)")
@export var dash_speed: float = 550.0          # Tốc độ lao vút khi bấm Shift
@export var dash_duration: float = 0.20        # Thời gian lướt (giây)
@export var dash_cooldown: float = 0.65        # Thời gian hồi giữa 2 lần lướt (giây)

@export_group("Chỉ Số Máu & Tội Lỗi (Blood & Guilt)")
@export var max_vessel: int = 100              # Máu tối đa của bình chứa
@export var base_attack: int = 22              # Sát thương chém kiếm gốc
@export var guilt_scaling: float = 1.2         # Hệ số tăng sát thương khi Guilt đầy (+120%)

# --- TRẠNG THÁI HIỆP SĨ (State Machine) ---
enum State {
	IDLE,       # Đang đứng yên
	RUN,        # Đang chạy
	JUMP,       # Đang bay lên
	FALL,       # Đang rơi xuống
	DASH,       # Đang lướt né đòn (bất tử)
	ATTACK_1,   # Chém nhát 1
	ATTACK_2,   # Chém nhát 2
	ATTACK_3,   # Chém nhát 3 (Finisher)
	VERDICT,    # Trừng Phạt chém kết liễu chí mạng
	HURT,       # Bị trúng đòn (giật lùi)
	ATONEMENT   # Đang sám hối hồi máu
}

var current_state: State = State.IDLE

# --- BIẾN TRẠNG THÁI GAMEPLAY ---
var current_blood: int = 100
var current_guilt: int = 0
var facing_direction: float = 1.0   # 1.0: Nhìn sang phải, -1.0: Nhìn sang trái

# Cửa sổ Combo & Thời gian hồi chiêu
var combo_step: int = 0             # 0: chưa chém, 1: chém 1, 2: chém 2, 3: chém 3
var combo_timer: float = 0.0        # Đếm ngược thời gian duy trì combo
var dash_timer: float = 0.0         # Đếm ngược thời gian đang lướt
var dash_cd_timer: float = 0.0      # Đếm ngược hồi chiêu lướt
var hurt_timer: float = 0.0         # Thời gian giật khựng khi trúng đòn
var atonement_timer: float = 0.0    # Đếm thời gian đang đứng sám hối

# Cơ chế hỗ trợ nhảy mượt (Game Feel)
var coyote_timer: float = 0.0       # Nhảy trễ khi hụt chân bục đá (0.1s)
var jump_buffer_timer: float = 0.0  # Bấm nhảy trước khi chạm đất (0.12s)

# --- CÁC NODE CON ĐƯỢC KẾT NỐI ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D
@onready var attack_hitbox: Hitbox = $AttackPivot/AttackHitbox
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var attack_pivot: Node2D = $AttackPivot
@onready var slash_arc: Line2D = $AttackPivot/SlashArc
@onready var dust_particles: CPUParticles2D = $DustParticles

# Mốc neo chân nhân vật
const SPRITE_BASE_Y: float = -75.0
var walk_anim_time: float = 0.0
var idle_anim_time: float = 0.0

# Signals thông báo trạng thái ra ngoài (cho thanh HUD đọc)
signal blood_changed(current: int, max_val: int)
signal guilt_changed(current: int, max_val: int)
signal frenzy_changed(multiplier: float)
signal player_died()

func _ready() -> void:
	add_to_group("player")
	current_blood = max_vessel
	current_guilt = 0
	blood_changed.emit(current_blood, max_vessel)
	guilt_changed.emit(current_guilt, max_vessel)
	
	# Mặc định tắt Hitbox (chỉ bật đúng tích tắc khi vung kiếm)
	attack_hitbox.monitoring = false
	attack_hitbox.monitorable = false
	attack_hitbox.source_attacker = self
	slash_arc.visible = false
	
	# Lắng nghe khi bị trúng đòn
	hurtbox.hit_received.connect(_on_hurtbox_hit_received)
	
	# Khóa vị trí trục Y chuẩn
	sprite.position.y = SPRITE_BASE_Y

func _unhandled_input(event: InputEvent) -> void:
	if current_state == State.HURT or current_state == State.ATONEMENT or current_state == State.VERDICT:
		return
		
	# Bắt các phím bấm bàn phím (chỉ ăn 1 lần bấm, không bị lặp phím)
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.physical_keycode == KEY_SPACE or event.physical_keycode == KEY_W:
			jump_buffer_timer = 0.15 # Đệm nhảy
		elif event.physical_keycode == KEY_SHIFT:
			if current_state in [State.IDLE, State.RUN, State.JUMP, State.FALL]:
				_start_dash()
		elif event.physical_keycode == KEY_J:
			if current_state in [State.IDLE, State.RUN, State.JUMP, State.FALL]:
				_execute_attack()
		elif event.physical_keycode == KEY_K:
			_sacrifice_blood()
		elif event.physical_keycode == KEY_L:
			_start_atonement()
		elif event.physical_keycode == KEY_E:
			_try_verdict()
			
	# Bắt chuột (Click Chuột Trái chém, Chuột Phải lướt)
	elif event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			if current_state in [State.IDLE, State.RUN, State.JUMP, State.FALL]:
				_execute_attack()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if current_state in [State.IDLE, State.RUN, State.JUMP, State.FALL]:
				_start_dash()

func _physics_process(delta: float) -> void:
	_update_timers(delta)
	
	# Điều phối hành vi theo từng trạng thái (State Machine)
	match current_state:
		State.IDLE, State.RUN, State.JUMP, State.FALL:
			_handle_movement(delta)
		State.DASH:
			_handle_dash(delta)
		State.ATTACK_1, State.ATTACK_2, State.ATTACK_3:
			_handle_attack_physics(delta)
		State.VERDICT:
			_handle_verdict_physics(delta)
		State.HURT:
			_handle_hurt_physics(delta)
		State.ATONEMENT:
			_handle_atonement(delta)

	move_and_slide()
	_update_visuals(delta)

# ==================== 1. QUẢN LÝ THỜI GIAN & HỒI CHIÊU ====================

func _update_timers(delta: float) -> void:
	if dash_cd_timer > 0.0:
		dash_cd_timer -= delta
		
	if combo_timer > 0.0:
		combo_timer -= delta
		if combo_timer <= 0.0:
			combo_step = 0 # Quá 0.5s không chém tiếp -> Reset combo về đòn 1
			
	# Coyote Time (bước hụt bục đá vẫn nhảy được)
	if is_on_floor():
		coyote_timer = 0.10
	else:
		coyote_timer = max(0.0, coyote_timer - delta)
		
	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta

# ==================== 2. DI CHUYỂN & NHẢY ====================

func _handle_movement(delta: float) -> void:
	# 1. Trọng lực (rơi nhanh hơn bay lên để cảm giác nhảy dứt khoát)
	if not is_on_floor():
		var applied_grav = gravity * (fall_gravity_mult if velocity.y > 0.0 else 1.0)
		velocity.y += applied_grav * delta
	
	# 2. Xử lý Input Nhảy (Space, W, Mũi tên lên)
	if Input.is_physical_key_pressed(KEY_SPACE) or Input.is_physical_key_pressed(KEY_W) or Input.is_action_just_pressed("ui_up"):
		jump_buffer_timer = 0.12 # Ghi nhớ lệnh nhảy
		
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		_play_dust()

	# 3. Xử lý Input Chạy (A / D / Trái / Phải)
	var move_input: float = 0.0
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT) or Input.is_action_pressed("ui_left"):
		move_input -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT) or Input.is_action_pressed("ui_right"):
		move_input += 1.0

	if move_input != 0.0:
		velocity.x = move_toward(velocity.x, move_input * move_speed, acceleration * delta)
		_set_facing(move_input)
		if is_on_floor():
			current_state = State.RUN
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		if is_on_floor():
			current_state = State.IDLE
			
	if not is_on_floor():
		current_state = State.JUMP if velocity.y < 0.0 else State.FALL

# Quay hướng nhân vật và lật vùng chém kiếm (AttackPivot)
func _set_facing(dir: float) -> void:
	facing_direction = sign(dir)
	sprite.flip_h = (facing_direction < 0.0)
	attack_pivot.scale.x = facing_direction

# ==================== 3. LƯỚT NÉ ĐÒN (DASH / DODGE ROLL) ====================

func _start_dash() -> void:
	if dash_cd_timer > 0.0:
		return # Đang hồi chiêu lướt
		
	current_state = State.DASH
	dash_timer = dash_duration
	dash_cd_timer = dash_cooldown
	hurtbox.is_invincible = true # BẬT BẤT TỬ trong lúc lướt!
	
	velocity.y = 0.0
	velocity.x = facing_direction * dash_speed
	
	# Hiệu ứng mờ bóng ma (Ghost Trail)
	_play_dust()
	var t = create_tween()
	t.tween_property(sprite, "modulate:a", 0.4, 0.05)
	t.tween_property(sprite, "modulate:a", 1.0, 0.15)

func _handle_dash(delta: float) -> void:
	dash_timer -= delta
	velocity.y = 0.0 # Lướt thẳng trên không
	velocity.x = facing_direction * dash_speed
	
	if dash_timer <= 0.0:
		hurtbox.is_invincible = false # TẮT BẤT TỬ
		current_state = State.IDLE if is_on_floor() else State.FALL

# ==================== 4. HỆ THỐNG TRỪNG PHẠT (VERDICT) & CHÉM COMBO ====================

# Phím [E]: Kiểm tra xem có kẻ địch nào trong tầm bị đầy 100 Sin không để tung đòn Trừng Phạt
func _try_verdict() -> void:
	if current_state in [State.DASH, State.HURT, State.ATONEMENT, State.VERDICT]:
		return
		
	var enemies = get_tree().get_nodes_in_group("enemies")
	var target = null
	var min_dist = 200.0 # Khoảng cách tối đa để có thể tung đòn Trừng Phạt
	
	for enemy in enemies:
		if is_instance_valid(enemy) and "is_verdict_ready" in enemy and enemy.is_verdict_ready:
			var d = global_position.distance_to(enemy.global_position)
			if d < min_dist:
				min_dist = d
				target = enemy
				
	if target:
		_execute_verdict(target)

func _execute_verdict(target: Node2D) -> void:
	current_state = State.VERDICT
	velocity = Vector2.ZERO
	
	# Hướng mặt về phía mục tiêu
	var dir_to_target = sign(target.global_position.x - global_position.x)
	if dir_to_target != 0.0:
		_set_facing(dir_to_target)
		
	# Lướt thần tốc áp sát trước mặt kẻ địch
	global_position.x = target.global_position.x - facing_direction * 45.0
	global_position.y = target.global_position.y
	
	# Ngưng đọng thời gian (Hit Stop) 0.15s tạo cảm giác va chạm cực mạnh
	Engine.time_scale = 0.1
	
	# Rung chấn màn hình mạnh
	_shake_camera(7.0, 0.3)
	
	# Vẽ nhát chém chữ X màu đỏ huyết
	_draw_verdict_cross_arc()
	
	# Thưởng Guilt cho Hiệp Sĩ khi thi triển Trừng Phạt thành công (+25 Cuồng Tội)
	current_guilt = min(max_vessel - current_blood, current_guilt + 25)
	blood_changed.emit(current_blood, max_vessel)
	guilt_changed.emit(current_guilt, max_vessel)
	frenzy_changed.emit(get_guilt_multiplier())
	
	# Chớp đỏ rực toàn thân nhân vật
	var t = create_tween()
	sprite.modulate = Color(4.0, 0.4, 0.4)
	t.tween_property(sprite, "modulate", Color.WHITE, 0.25)
	
	# Sát thương Trừng Phạt cực lớn có nhân hệ số Frenzy
	var verdict_dmg = int(140.0 * get_guilt_multiplier())
	if target.has_method("receive_verdict"):
		target.receive_verdict(verdict_dmg)
		
	# Trả lại tốc độ thời gian chuẩn sau tích tắc
	await get_tree().create_timer(0.12 * 0.1).timeout
	Engine.time_scale = 1.0
	
	await get_tree().create_timer(0.2).timeout
	if current_state == State.VERDICT:
		current_state = State.IDLE if is_on_floor() else State.FALL

func _handle_verdict_physics(delta: float) -> void:
	velocity = Vector2.ZERO

func _shake_camera(strength: float, duration: float) -> void:
	if not camera:
		return
	var t = create_tween()
	var steps = 4
	for i in range(steps):
		var rand_offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		t.tween_property(camera, "offset", rand_offset, duration / float(steps))
	t.tween_property(camera, "offset", Vector2.ZERO, 0.05)

func _execute_attack() -> void:
	# Xác định nhát chém tiếp theo trong chuỗi combo (1 -> 2 -> 3 -> 1)
	combo_step = (combo_step % 3) + 1
	combo_timer = 0.55 # Cho phép 0.55 giây để bấm nhát chém tiếp theo
	
	var multiplier = get_guilt_multiplier()
	
	match combo_step:
		1:
			current_state = State.ATTACK_1
			_perform_slash(18, 15, 120.0, 0.22, Color(2.0, 2.0, 2.0), multiplier)
		2:
			current_state = State.ATTACK_2
			_perform_slash(24, 20, 160.0, 0.22, Color(2.2, 1.8, 0.8), multiplier)
		3:
			current_state = State.ATTACK_3
			_perform_slash(42, 35, 260.0, 0.35, Color(3.0, 0.4, 0.4), multiplier) # Finisher nện đất

func _perform_slash(raw_dmg: int, sin_amt: int, knockback: float, duration: float, arc_color: Color, multiplier: float) -> void:
	# Tính sát thương có nhân hệ số Cuồng Tội (Frenzy)
	var final_damage = int(float(raw_dmg) * multiplier)
	
	# Cài đặt thông số cho Hitbox
	attack_hitbox.damage = final_damage
	attack_hitbox.sin_inflict = sin_amt
	attack_hitbox.knockback_force = knockback
	attack_hitbox.is_verdict = false
	
	# Hiệp sĩ hơi trượt tới trước một chút (Attack Lunge)
	velocity.x = facing_direction * 180.0
	
	# Bật Hitbox gây sát thương
	attack_hitbox.monitoring = true
	attack_hitbox.monitorable = true
	
	# Vẽ vệt kiếm chém (Slash Arc)
	_draw_slash_arc(arc_color, combo_step)
	
	# Hoạt ảnh nghiêng người vung kiếm
	var t = create_tween()
	var swing_rot = 18.0 if combo_step != 2 else -22.0
	t.tween_property(sprite, "rotation_degrees", swing_rot * facing_direction, 0.08)
	t.tween_property(sprite, "rotation_degrees", 0.0, duration - 0.08)
	
	# Tự tắt Hitbox sau khi chém xong
	await get_tree().create_timer(duration * 0.7).timeout
	attack_hitbox.monitoring = false
	attack_hitbox.monitorable = false
	
	await get_tree().create_timer(duration * 0.3).timeout
	if current_state in [State.ATTACK_1, State.ATTACK_2, State.ATTACK_3]:
		current_state = State.IDLE if is_on_floor() else State.FALL

func _handle_attack_physics(delta: float) -> void:
	# Khi đang chém thì giảm tốc dần, nhưng vẫn có trọng lực
	if not is_on_floor():
		velocity.y += gravity * delta
	velocity.x = move_toward(velocity.x, 0.0, friction * 1.5 * delta)

# ==================== 5. VẼ VỆT KIẾM CHÉM (SLASH BLADE ARC FX) ====================

func _draw_slash_arc(color: Color, step: int) -> void:
	slash_arc.visible = true
	slash_arc.default_color = color
	slash_arc.width = 12.0 if step == 3 else 8.0
	
	if step == 1:
		# Chém ngang
		slash_arc.points = PackedVector2Array([Vector2(10, -95), Vector2(65, -75), Vector2(95, -50), Vector2(70, -20)])
	elif step == 2:
		# Chém chéo hất ngược
		slash_arc.points = PackedVector2Array([Vector2(20, -25), Vector2(80, -45), Vector2(100, -85), Vector2(60, -125)])
	else:
		# Đòn 3: Nện từ trên cao xé toạc đất
		slash_arc.points = PackedVector2Array([Vector2(30, -140), Vector2(105, -85), Vector2(115, -20), Vector2(60, 5)])
		_play_dust()
		
	var t = create_tween()
	t.tween_property(slash_arc, "width", 0.0, 0.18).set_trans(Tween.TRANS_QUAD)
	t.tween_callback(func(): slash_arc.visible = false)

func _draw_verdict_cross_arc() -> void:
	slash_arc.visible = true
	slash_arc.default_color = Color(3.5, 0.2, 0.2, 1.0)
	slash_arc.width = 16.0
	slash_arc.points = PackedVector2Array([
		Vector2(-40, -120), Vector2(40, -20), Vector2(0, -70), Vector2(-40, -20), Vector2(40, -120)
	])
	var t = create_tween()
	t.tween_property(slash_arc, "width", 0.0, 0.3).set_trans(Tween.TRANS_QUAD)
	t.tween_callback(func(): slash_arc.visible = false)

# ==================== 6. CƠ CHẾ BLOOD & GUILT (BÌNH THÔNG NHAU) ====================

# Khi Hiệp Sĩ bị trúng đòn từ quái vật
func _on_hurtbox_hit_received(incoming_hitbox: Hitbox) -> void:
	if current_state == State.DASH:
		return # Đang lướt bất tử, không thể dính đòn
		
	var dmg = incoming_hitbox.damage
	current_blood = max(0, current_blood - dmg)
	
	# MÁU MẤT BIẾN THÀNH TỘI LỖI (GUILT)
	current_guilt = min(max_vessel - current_blood, current_guilt + dmg)
	
	blood_changed.emit(current_blood, max_vessel)
	guilt_changed.emit(current_guilt, max_vessel)
	frenzy_changed.emit(get_guilt_multiplier())
	
	# Giật lùi và chớp đỏ
	current_state = State.HURT
	hurt_timer = 0.22
	var push_dir = -facing_direction
	if incoming_hitbox.source_attacker:
		push_dir = sign(global_position.x - incoming_hitbox.source_attacker.global_position.x)
	velocity = Vector2(push_dir * 220.0, -180.0)
	
	var t = create_tween()
	t.tween_property(sprite, "modulate", Color(3.5, 0.4, 0.4), 0.08)
	t.tween_property(sprite, "modulate", Color.WHITE, 0.14)
	
	if current_blood <= 0:
		player_died.emit()

func _handle_hurt_physics(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	hurt_timer -= delta
	if hurt_timer <= 0.0:
		current_state = State.IDLE if is_on_floor() else State.FALL

# Phím K: Tự rạch máu hi sinh để tích Cuồng Tội
func _sacrifice_blood() -> void:
	if current_blood <= 20:
		return # Không tự sát được
	current_blood -= 20
	current_guilt = min(max_vessel - current_blood, current_guilt + 20)
	blood_changed.emit(current_blood, max_vessel)
	guilt_changed.emit(current_guilt, max_vessel)
	frenzy_changed.emit(get_guilt_multiplier())
	
	var t = create_tween()
	t.tween_property(sprite, "modulate", Color(2.5, 0.2, 0.2), 0.1)
	t.tween_property(sprite, "modulate", Color.WHITE, 0.2)

# Phím L: Sám Hối đổi Guilt hồi Máu
func _start_atonement() -> void:
	if current_guilt <= 0 or not is_on_floor():
		return
	current_state = State.ATONEMENT
	atonement_timer = 0.6
	velocity = Vector2.ZERO
	
	var restored = current_guilt
	current_blood = min(max_vessel, current_blood + restored)
	current_guilt = 0
	
	blood_changed.emit(current_blood, max_vessel)
	guilt_changed.emit(current_guilt, max_vessel)
	frenzy_changed.emit(get_guilt_multiplier())
	
	var t = create_tween()
	t.tween_property(sprite, "modulate", Color(1.2, 2.5, 1.8), 0.3)
	t.tween_property(sprite, "modulate", Color.WHITE, 0.3)

func _handle_atonement(delta: float) -> void:
	velocity = Vector2.ZERO
	atonement_timer -= delta
	if atonement_timer <= 0.0:
		current_state = State.IDLE

func get_guilt_multiplier() -> float:
	var ratio = float(current_guilt) / float(max(1, max_vessel))
	return 1.0 + (ratio * guilt_scaling)

# ==================== 7. HIỆU ỨNG NHÌN (GAME FEEL & PARTICLES) ====================

func _update_visuals(delta: float) -> void:
	# Nhấp nhô nhịp bước chân khi chạy
	if current_state == State.RUN and is_on_floor():
		walk_anim_time += delta * 15.0
		sprite.position.y = SPRITE_BASE_Y + sin(walk_anim_time) * 3.5
	elif current_state == State.IDLE and is_on_floor():
		idle_anim_time += delta * 2.5
		sprite.position.y = SPRITE_BASE_Y + sin(idle_anim_time) * 2.0
	else:
		sprite.position.y = SPRITE_BASE_Y

func _play_dust() -> void:
	if dust_particles:
		dust_particles.restart()
