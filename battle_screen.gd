extends Control

# Nodes
@onready var arena = $Arena
@onready var player_sprite = $Arena/PlayerContainer/PlayerSprite
@onready var enemy_sprite = $Arena/EnemyContainer/EnemySprite
@onready var blood_particles = $Arena/BloodParticles
@onready var slash_arc = $Arena/SlashArc

# Player UI (Inside TopBar)
@onready var player_avatar = $HUD/TopBar/PlayerPanel/HBox/AvatarFrame/Avatar
@onready var player_blood_bar = $HUD/TopBar/PlayerPanel/HBox/VBox/BloodBar
@onready var player_blood_label = $HUD/TopBar/PlayerPanel/HBox/VBox/BloodBar/Label
@onready var player_guilt_bar = $HUD/TopBar/PlayerPanel/HBox/VBox/GuiltBar
@onready var player_guilt_label = $HUD/TopBar/PlayerPanel/HBox/VBox/GuiltBar/Label
@onready var player_frenzy_label = $HUD/TopBar/PlayerPanel/HBox/VBox/FrenzyLabel

# Round Badge
@onready var turn_label = $HUD/TopBar/CenterBadge/BadgePanel/TurnLabel

# Enemy UI (Inside TopBar)
@onready var enemy_blood_bar = $HUD/TopBar/EnemyPanel/HBox/VBox/BloodBar
@onready var enemy_blood_label = $HUD/TopBar/EnemyPanel/HBox/VBox/BloodBar/Label
@onready var enemy_sin_bar = $HUD/TopBar/EnemyPanel/HBox/VBox/SinBar
@onready var enemy_sin_label = $HUD/TopBar/EnemyPanel/HBox/VBox/SinBar/Label
@onready var enemy_stun_tag = $HUD/TopBar/EnemyPanel/HBox/VBox/StunTag

# Damage Text Container
@onready var damage_text_container = $HUD/DamageTextContainer

# Command Buttons (Inside CommandBar Bottom)
@onready var btn_slash = $HUD/CommandBar/HBox/BtnSlash
@onready var btn_blood_cleave = $HUD/CommandBar/HBox/BtnBloodCleave
@onready var btn_sin_smite = $HUD/CommandBar/HBox/BtnSinSmite
@onready var btn_atonement = $HUD/CommandBar/HBox/BtnAtonement
@onready var btn_verdict = $HUD/CommandBar/HBox/BtnVerdict

var battle_manager: BattleManager
var player: Battler
var enemy: Battler

var original_arena_pos: Vector2
var player_base_pos: Vector2
var enemy_base_pos: Vector2
var shake_strength: float = 0.0

func _ready() -> void:
	original_arena_pos = arena.position
	player_base_pos = player_sprite.position
	enemy_base_pos = enemy_sprite.position
	
	_setup_battlers()
	_setup_battle_manager()
	_start_breathing_animation()
	
	# Connect Button Events
	btn_slash.pressed.connect(_on_btn_slash_pressed)
	btn_blood_cleave.pressed.connect(_on_btn_blood_cleave_pressed)
	btn_sin_smite.pressed.connect(_on_btn_sin_smite_pressed)
	btn_atonement.pressed.connect(_on_btn_atonement_pressed)
	btn_verdict.pressed.connect(_on_btn_verdict_pressed)
	
	_update_ui_state()

func _setup_battlers() -> void:
	# 1. Setup Player Stats & Node
	var player_stats = BattlerStats.new()
	player_stats.battler_name = "Hiệp Sĩ Khổ Hạnh"
	player_stats.max_vessel = 100
	player_stats.base_attack = 22
	player_stats.guilt_scaling = 1.2
	player_stats.speed = 12
	player_stats.armor_percent = 0.10
	
	player = Battler.new()
	add_child(player)
	player.setup(player_stats, GlobalEnums.Faction.PLAYER)
	
	player.blood_changed.connect(_on_player_blood_changed)
	player.guilt_changed.connect(_on_player_guilt_changed)
	
	# 2. Setup Boss Stats & Node
	var boss_stats = BattlerStats.new()
	boss_stats.battler_name = "Kẻ Cai Ngục Khóc Máu"
	boss_stats.max_blood = 160
	boss_stats.max_sin = 100
	boss_stats.base_attack = 25
	boss_stats.speed = 8
	boss_stats.armor_percent = 0.05
	
	enemy = Battler.new()
	add_child(enemy)
	enemy.setup(boss_stats, GlobalEnums.Faction.ENEMY)
	
	enemy.blood_changed.connect(_on_enemy_blood_changed)
	enemy.sin_changed.connect(_on_enemy_sin_changed)
	enemy.stunned_state_changed.connect(_on_enemy_stunned_changed)

func _setup_battle_manager() -> void:
	battle_manager = BattleManager.new()
	add_child(battle_manager)
	
	battle_manager.state_changed.connect(_on_state_changed)
	battle_manager.screen_shake_requested.connect(_trigger_shake)
	battle_manager.enemy_attack_triggered.connect(_on_enemy_attack_triggered)
	battle_manager.enemy_stun_skipped.connect(_on_enemy_stun_skipped)
	
	battle_manager.setup_battle(player, enemy)

# ==================== IDLE BREATHING ANIMATION ====================

func _start_breathing_animation() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(player_sprite, "position:y", player_base_pos.y - 6.0, 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(player_sprite, "position:y", player_base_pos.y, 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	var enemy_tween = create_tween().set_loops()
	enemy_tween.tween_property(enemy_sprite, "position:y", enemy_base_pos.y - 5.0, 2.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	enemy_tween.tween_property(enemy_sprite, "position:y", enemy_base_pos.y, 2.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# ==================== SCREEN SHAKE & PROCESS ====================

func _process(delta: float) -> void:
	if shake_strength > 0.0:
		shake_strength = lerp(shake_strength, 0.0, delta * 12.0)
		var offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
		arena.position = original_arena_pos + offset
	else:
		arena.position = original_arena_pos

func _trigger_shake(strength: float) -> void:
	shake_strength = strength

# ==================== FLOATING COMBAT NUMBERS ====================

func spawn_floating_text(global_pos: Vector2, text: String, color: Color, font_size: int = 18, is_crit: bool = false) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	label.global_position = global_pos + Vector2(randf_range(-15, 15), randf_range(-10, 10))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	damage_text_container.add_child(label)
	
	var tween = create_tween()
	if is_crit:
		label.scale = Vector2(1.5, 1.5)
		tween.tween_property(label, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BOUNCE)
	
	tween.parallel().tween_property(label, "position:y", label.position.y - 70.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_callback(label.queue_free)

# ==================== UI STATE & SIGNALS ====================

func _on_player_blood_changed(current: int, max_val: int) -> void:
	player_blood_bar.max_value = max_val
	player_blood_bar.value = current
	player_blood_label.text = "MÁU: %d / %d" % [current, max_val]

func _on_player_guilt_changed(current: int, max_val: int) -> void:
	player_guilt_bar.max_value = max_val
	player_guilt_bar.value = current
	player_guilt_label.text = "TỘI LỖI (GUILT): %d / %d" % [current, max_val]
	
	var multiplier = player.get_guilt_multiplier()
	var bonus_pct = int((multiplier - 1.0) * 100.0)
	if bonus_pct > 0:
		player_frenzy_label.text = "🔥 CUỒNG TỘI: +%d%% SÁT THƯƠNG!" % bonus_pct
		player_frenzy_label.modulate = Color(1.0, 0.35, 0.35)
	else:
		player_frenzy_label.text = "CUỒNG TỘI: +0% SÁT THƯƠNG"
		player_frenzy_label.modulate = Color(0.7, 0.7, 0.7)

func _on_enemy_blood_changed(current: int, max_val: int) -> void:
	enemy_blood_bar.max_value = max_val
	enemy_blood_bar.value = current
	enemy_blood_label.text = "MÁU: %d / %d" % [current, max_val]

func _on_enemy_sin_changed(current: int, max_val: int) -> void:
	enemy_sin_bar.max_value = max_val
	enemy_sin_bar.value = current
	enemy_sin_label.text = "NGHIỆP TỘI (SIN): %d / %d" % [current, max_val]
	_update_verdict_button_state()

func _on_enemy_stunned_changed(stunned: bool) -> void:
	enemy_stun_tag.visible = stunned
	if stunned:
		var t = create_tween()
		t.tween_property(enemy_sprite, "modulate", Color(2.5, 2.0, 0.5), 0.2)
		t.tween_property(enemy_sprite, "modulate", Color.WHITE, 0.3)

func _on_state_changed(new_state: GlobalEnums.BattleState) -> void:
	_update_ui_state()
	
	if new_state == GlobalEnums.BattleState.PLAYER_TURN:
		turn_label.text = "⚔️ VÒNG %d: LƯỢT CỦA BẠN" % battle_manager.round_count
		turn_label.modulate = Color(0.9, 0.85, 0.75)
	elif new_state == GlobalEnums.BattleState.ENEMY_TURN:
		turn_label.text = "👹 LƯỢT CỦA KẺ CAI NGỤC..."
		turn_label.modulate = Color(1.0, 0.45, 0.45)
		await get_tree().create_timer(0.6).timeout
		battle_manager.run_enemy_turn()
	elif new_state == GlobalEnums.BattleState.VICTORY:
		turn_label.text = "🏆 CHIẾN THẮNG QUỶ DỮ!"
		turn_label.modulate = Color(0.4, 1.0, 0.5)
		await get_tree().create_timer(2.2).timeout
		GameManager.finish_battle(true)
	elif new_state == GlobalEnums.BattleState.DEFEAT:
		turn_label.text = "💀 BẠN ĐÃ TỬ TRẬN!"
		turn_label.modulate = Color(0.9, 0.2, 0.2)
		await get_tree().create_timer(2.5).timeout
		GameManager.reset_progress()
		get_tree().change_scene_to_file("res://scenes/exploration/catacomb_hallway.tscn")

func _update_ui_state() -> void:
	var is_player_turn = (battle_manager.state == GlobalEnums.BattleState.PLAYER_TURN)
	btn_slash.disabled = not is_player_turn
	btn_blood_cleave.disabled = not is_player_turn or (player.current_blood <= 20)
	btn_sin_smite.disabled = not is_player_turn
	btn_atonement.disabled = not is_player_turn or (player.current_guilt <= 0)
	
	_update_verdict_button_state()

func _update_verdict_button_state() -> void:
	# CƠ CHẾ SIN: Nút Trừng Phạt sáng rực và bấm được BẤT CỨ LÚC NÀO MIỄN LÀ THANH SIN CỦA BOSS ĐANG Ở MỨC TỐI ĐA (>= 100)
	var sin_is_max = (enemy.current_sin >= enemy.stats.max_sin)
	var can_verdict = (battle_manager.state == GlobalEnums.BattleState.PLAYER_TURN and sin_is_max)
	btn_verdict.disabled = not can_verdict
	
	if sin_is_max:
		btn_verdict.text = "⚔️ [TRỪNG PHẠT] ⚔️\n(CHÍ MẠNG XÓA TỘI!)"
		btn_verdict.modulate = Color(2.5, 0.4, 0.4) # Glowing crimson
	else:
		btn_verdict.text = "⚖️ TRỪNG PHẠT\n[Cần 100 Sin để kích hoạt]"
		btn_verdict.modulate = Color(0.6, 0.6, 0.6)

# ==================== VISUAL ATTACK ANIMATIONS ====================

func _play_slash_blade_arc(target_pos: Vector2, color: Color) -> void:
	slash_arc.points = PackedVector2Array([
		target_pos + Vector2(-60, -70),
		target_pos + Vector2(0, -20),
		target_pos + Vector2(70, 40),
		target_pos + Vector2(100, 90)
	])
	slash_arc.default_color = color
	slash_arc.visible = true
	slash_arc.width = 10.0
	
	var t = create_tween()
	t.tween_property(slash_arc, "width", 0.0, 0.22).set_trans(Tween.TRANS_QUAD)
	t.tween_callback(func(): slash_arc.visible = false)

func _on_btn_slash_pressed() -> void:
	# Hiệp sĩ lao tới chém
	var t = create_tween()
	t.tween_property(player_sprite, "position:x", player_base_pos.x + 160.0, 0.14).set_trans(Tween.TRANS_QUAD)
	t.tween_callback(func():
		var enemy_hit_pos = enemy_sprite.global_position + Vector2(160, 160)
		_play_slash_blade_arc(enemy_hit_pos, Color(2.0, 2.0, 2.0))
		
		# Boss Hit Flash & Blood
		_hit_flash_enemy(Color(3.5, 3.5, 3.5))
		_emit_blood(enemy_hit_pos)
		
		# Tính toán sát thương
		var res = battle_manager.player_slash()
		spawn_floating_text(enemy_hit_pos + Vector2(0, -60), "-%d MÁU" % res["actual_blood_damage"], Color(1.0, 0.3, 0.3), 22)
		if res["sin_inflicted"] > 0:
			spawn_floating_text(enemy_hit_pos + Vector2(0, -25), "+%d SIN" % res["sin_inflicted"], Color(1.0, 0.85, 0.2), 18)
		if res["caused_stun"]:
			spawn_floating_text(enemy_hit_pos + Vector2(0, -95), "⚡ CHOÁNG 1 LƯỢT!", Color(1.0, 0.9, 0.3), 22, true)
	)
	t.tween_property(player_sprite, "position:x", player_base_pos.x, 0.25).set_trans(Tween.TRANS_QUAD)

func _on_btn_blood_cleave_pressed() -> void:
	# Hiệp sĩ chồm cao chém đẫm máu
	var t = create_tween()
	t.tween_property(player_sprite, "position", Vector2(player_base_pos.x + 190.0, player_base_pos.y - 30.0), 0.13).set_trans(Tween.TRANS_QUAD)
	t.parallel().tween_property(player_sprite, "modulate", Color(3.0, 0.4, 0.4), 0.13)
	t.tween_callback(func():
		var enemy_hit_pos = enemy_sprite.global_position + Vector2(160, 160)
		_play_slash_blade_arc(enemy_hit_pos, Color(3.0, 0.2, 0.2))
		
		_hit_flash_enemy(Color(3.5, 0.3, 0.3))
		_emit_blood(enemy_hit_pos)
		
		var res = battle_manager.player_blood_cleave()
		spawn_floating_text(enemy_hit_pos + Vector2(0, -60), "-%d MÁU [HUYẾT TRẢM]" % res["actual_blood_damage"], Color(1.0, 0.2, 0.2), 24, true)
		if res["sin_inflicted"] > 0:
			spawn_floating_text(enemy_hit_pos + Vector2(0, -25), "+%d SIN" % res["sin_inflicted"], Color(1.0, 0.85, 0.2), 18)
		if res["caused_stun"]:
			spawn_floating_text(enemy_hit_pos + Vector2(0, -95), "⚡ CHOÁNG 1 LƯỢT!", Color(1.0, 0.9, 0.3), 22, true)
	)
	t.tween_property(player_sprite, "position", player_base_pos, 0.28).set_trans(Tween.TRANS_QUAD)
	t.parallel().tween_property(player_sprite, "modulate", Color.WHITE, 0.28)

func _on_btn_sin_smite_pressed() -> void:
	# Khổ hình búa vàng kim nện xuống
	var t = create_tween()
	t.tween_property(player_sprite, "position:x", player_base_pos.x + 140.0, 0.15).set_trans(Tween.TRANS_QUAD)
	t.parallel().tween_property(player_sprite, "modulate", Color(2.0, 1.6, 0.4), 0.15)
	t.tween_callback(func():
		var enemy_hit_pos = enemy_sprite.global_position + Vector2(160, 160)
		_play_slash_blade_arc(enemy_hit_pos, Color(2.5, 2.0, 0.4))
		
		_hit_flash_enemy(Color(2.5, 2.0, 0.4))
		_emit_blood(enemy_hit_pos)
		
		var res = battle_manager.player_sin_smite()
		spawn_floating_text(enemy_hit_pos + Vector2(0, -60), "-%d MÁU" % res["actual_blood_damage"], Color(1.0, 0.4, 0.4), 18)
		spawn_floating_text(enemy_hit_pos + Vector2(0, -25), "+%d SIN! [KHỔ HÌNH]" % res["sin_inflicted"], Color(1.0, 0.9, 0.2), 24, true)
		if res["caused_stun"]:
			spawn_floating_text(enemy_hit_pos + Vector2(0, -95), "⚡ CHOÁNG 1 LƯỢT!", Color(1.0, 0.9, 0.3), 22, true)
	)
	t.tween_property(player_sprite, "position:x", player_base_pos.x, 0.25).set_trans(Tween.TRANS_QUAD)
	t.parallel().tween_property(player_sprite, "modulate", Color.WHITE, 0.25)

func _on_btn_atonement_pressed() -> void:
	# Sám hối hồi phục
	var t = create_tween()
	t.tween_property(player_sprite, "modulate", Color(1.2, 2.5, 1.8), 0.3)
	t.tween_property(player_sprite, "modulate", Color.WHITE, 0.4)
	
	var healed = battle_manager.player_atonement()
	var player_hit_pos = player_sprite.global_position + Vector2(160, 100)
	spawn_floating_text(player_hit_pos + Vector2(0, -50), "+%d MÁU [SÁM HỐI]" % healed, Color(0.3, 1.0, 0.6), 24, true)

func _on_btn_verdict_pressed() -> void:
	# ĐẠI TRỪNG PHẠT - Đòn chém kết liễu tối thượng
	var t = create_tween()
	t.tween_property(player_sprite, "position:x", player_base_pos.x + 240.0, 0.22).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(player_sprite, "modulate", Color(3.5, 0.4, 0.4), 0.22)
	t.tween_callback(func():
		var enemy_hit_pos = enemy_sprite.global_position + Vector2(160, 160)
		_play_slash_blade_arc(enemy_hit_pos, Color(4.0, 0.5, 0.5))
		
		_hit_flash_enemy(Color(4.0, 0.2, 0.2))
		_emit_blood(enemy_hit_pos)
		
		var res = battle_manager.player_verdict()
		spawn_floating_text(enemy_hit_pos + Vector2(0, -70), "☠️ %d CHÍ MẠNG! [TRỪNG PHẠT]" % res["actual_blood_damage"], Color(1.0, 0.15, 0.15), 28, true)
		spawn_floating_text(enemy_hit_pos + Vector2(0, -30), "✨ SIN ĐÃ ĐƯỢC RỬA SẠCH VỀ 0!", Color(1.0, 0.95, 0.5), 18)
	)
	t.tween_property(player_sprite, "position:x", player_base_pos.x, 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(player_sprite, "modulate", Color.WHITE, 0.4)

# ==================== ENEMY ATTACK ANIMATION ====================

func _on_enemy_attack_triggered(attack_name: String, raw_dmg: int, is_heavy: bool) -> void:
	# 1. Kẻ Cai Ngục co người lấy đà (Wind-up)
	var t = create_tween()
	t.tween_property(enemy_sprite, "position:x", enemy_base_pos.x + 45.0, 0.25).set_trans(Tween.TRANS_SINE)
	t.parallel().tween_property(enemy_sprite, "modulate", Color(1.8, 0.4, 0.4) if is_heavy else Color(1.4, 0.8, 0.8), 0.25)
	
	# 2. Lao bổ vào Hiệp Sĩ vung xích gai / thiết bổng
	t.tween_property(enemy_sprite, "position:x", enemy_base_pos.x - 240.0, 0.16).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	t.tween_callback(func():
		var player_hit_pos = player_sprite.global_position + Vector2(160, 160)
		_play_slash_blade_arc(player_hit_pos, Color(2.5, 0.3, 0.3) if is_heavy else Color(2.0, 1.2, 0.5))
		
		# Hiệp sĩ ăn đòn: Chớp đỏ, giật lùi, văng máu
		_hit_flash_player(Color(3.5, 0.3, 0.3))
		_emit_blood(player_hit_pos)
		
		var recoilt = create_tween()
		recoilt.tween_property(player_sprite, "position:x", player_base_pos.x - 35.0, 0.1)
		recoilt.tween_property(player_sprite, "position:x", player_base_pos.x, 0.25)
		
		# Áp dụng sát thương qua BattleManager
		var res = battle_manager.apply_enemy_attack(raw_dmg, is_heavy)
		var dmg_val = res["actual_blood_damage"]
		
		var title_txt = "⚡ ĐÒN NẶNG: %s" % attack_name if is_heavy else attack_name
		spawn_floating_text(player_hit_pos + Vector2(0, -65), "-%d MÁU [%s]" % [dmg_val, title_txt], Color(1.0, 0.25, 0.25), 22, is_heavy)
		spawn_floating_text(player_hit_pos + Vector2(0, -30), "+%d GUILT!" % dmg_val, Color(0.85, 0.3, 1.0), 18)
	)
	
	# 3. Quái vật lùi về vị trí chờ
	t.tween_property(enemy_sprite, "position:x", enemy_base_pos.x, 0.35).set_trans(Tween.TRANS_QUAD)
	t.parallel().tween_property(enemy_sprite, "modulate", Color.WHITE, 0.35)

func _on_enemy_stun_skipped() -> void:
	# Quái vật lảo đảo vì Choáng, mất 1 lượt
	var enemy_hit_pos = enemy_sprite.global_position + Vector2(160, 100)
	spawn_floating_text(enemy_hit_pos + Vector2(0, -50), "🌀 CHOÁNG! QUÁI VẬT MẤT LƯỢT!", Color(1.0, 0.85, 0.2), 22, true)
	
	var t = create_tween()
	t.tween_property(enemy_sprite, "position:x", enemy_base_pos.x - 20.0, 0.15)
	t.tween_property(enemy_sprite, "position:x", enemy_base_pos.x + 20.0, 0.15)
	t.tween_property(enemy_sprite, "position:x", enemy_base_pos.x, 0.15)
	
	await t.finished
	await get_tree().create_timer(0.6).timeout
	battle_manager._end_round()

# ==================== HELPERS ====================

func _hit_flash_enemy(col: Color) -> void:
	var t = create_tween()
	t.tween_property(enemy_sprite, "modulate", col, 0.08)
	t.tween_property(enemy_sprite, "modulate", Color.WHITE, 0.12)

func _hit_flash_player(col: Color) -> void:
	var t = create_tween()
	t.tween_property(player_sprite, "modulate", col, 0.08)
	t.tween_property(player_sprite, "modulate", Color.WHITE, 0.12)

func _emit_blood(hit_global_pos: Vector2) -> void:
	blood_particles.global_position = hit_global_pos
	blood_particles.restart()
