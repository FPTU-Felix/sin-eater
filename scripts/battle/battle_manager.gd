class_name BattleManager
extends Node

signal state_changed(new_state: GlobalEnums.BattleState)
signal screen_shake_requested(strength: float)
signal enemy_attack_triggered(attack_name: String, raw_damage: int, is_heavy: bool)
signal enemy_stun_skipped()

var player: Battler
var enemy: Battler
var state: GlobalEnums.BattleState = GlobalEnums.BattleState.PLAYER_TURN
var round_count: int = 1

func setup_battle(p_player: Battler, p_enemy: Battler) -> void:
	player = p_player
	enemy = p_enemy
	round_count = 1
	state = GlobalEnums.BattleState.PLAYER_TURN
	state_changed.emit(state)

# ==================== PLAYER ACTIONS ====================

func player_slash() -> Dictionary:
	if state != GlobalEnums.BattleState.PLAYER_TURN or player.is_dead:
		return {}
	
	state = GlobalEnums.BattleState.EXECUTING
	state_changed.emit(state)
	
	var multiplier = player.get_guilt_multiplier()
	var raw_damage = int(float(player.stats.base_attack) * multiplier)
	var sin_inflict = 20
	
	var dmg_data = DamageData.new(raw_damage, sin_inflict, false, multiplier > 1.4, "Hiệp Sĩ")
	var result = enemy.take_hit(dmg_data)
	
	screen_shake_requested.emit(5.0 if multiplier > 1.3 else 3.0)
	_check_post_player_action()
	return result

func player_blood_cleave() -> Dictionary:
	if state != GlobalEnums.BattleState.PLAYER_TURN or player.is_dead:
		return {}
		
	state = GlobalEnums.BattleState.EXECUTING
	state_changed.emit(state)
	
	var blood_cost = 20
	var sacrificed = player.sacrifice_blood(blood_cost)
	
	var multiplier = player.get_guilt_multiplier()
	var raw_damage = int(float(player.stats.base_attack) * 1.8 * multiplier)
	var sin_inflict = 25
	
	var dmg_data = DamageData.new(raw_damage, sin_inflict, false, true, "Hiệp Sĩ")
	var result = enemy.take_hit(dmg_data)
	result["sacrificed_blood"] = sacrificed
	
	screen_shake_requested.emit(8.0)
	_check_post_player_action()
	return result

func player_sin_smite() -> Dictionary:
	if state != GlobalEnums.BattleState.PLAYER_TURN or player.is_dead:
		return {}
		
	state = GlobalEnums.BattleState.EXECUTING
	state_changed.emit(state)
	
	var multiplier = player.get_guilt_multiplier()
	var raw_damage = int(float(player.stats.base_attack) * 0.6 * multiplier)
	var sin_inflict = 45 # Nhồi nhiều Sin để nhanh chạm mốc 100
	
	var dmg_data = DamageData.new(raw_damage, sin_inflict, false, false, "Hiệp Sĩ")
	var result = enemy.take_hit(dmg_data)
	
	screen_shake_requested.emit(6.0)
	_check_post_player_action()
	return result

func player_atonement() -> int:
	if state != GlobalEnums.BattleState.PLAYER_TURN or player.is_dead:
		return 0
		
	state = GlobalEnums.BattleState.EXECUTING
	state_changed.emit(state)
	
	if player.current_guilt <= 0:
		state = GlobalEnums.BattleState.PLAYER_TURN
		state_changed.emit(state)
		return 0
		
	var healed = player.perform_atonement()
	screen_shake_requested.emit(3.0)
	
	_check_post_player_action()
	return healed

func player_verdict() -> Dictionary:
	if state != GlobalEnums.BattleState.PLAYER_TURN or player.is_dead:
		return {}
		
	# Bấm được bất cứ lúc nào MIỄN LÀ THANH SIN CỦA BOSS ĐANG Ở MỨC TỐI ĐA (>= 100)
	if enemy.current_sin < enemy.stats.max_sin:
		return {}
		
	state = GlobalEnums.BattleState.EXECUTING
	state_changed.emit(state)
	
	var multiplier = player.get_guilt_multiplier()
	var raw_damage = int(85.0 * multiplier) # Đòn trừng phạt chí mạng khổng lồ
	
	# is_verdict = true -> Battler sẽ xóa sạch 100 Sin về 0
	var dmg_data = DamageData.new(raw_damage, 0, true, true, "Hiệp Sĩ")
	var result = enemy.take_hit(dmg_data)
	
	screen_shake_requested.emit(16.0)
	_check_post_player_action()
	return result

func _check_post_player_action() -> void:
	if enemy.is_dead:
		state = GlobalEnums.BattleState.VICTORY
		state_changed.emit(state)
		return
		
	# Chuyển lượt sang quái vật
	state = GlobalEnums.BattleState.ENEMY_TURN
	state_changed.emit(state)

# ==================== ENEMY ACTIONS ====================

func run_enemy_turn() -> void:
	if state != GlobalEnums.BattleState.ENEMY_TURN or enemy.is_dead:
		return
		
	# 1. Nếu Boss đang bị Choáng ở lượt đầu tiên khi Sin đạt max -> Mất lượt!
	if enemy.is_stunned:
		enemy.recover_from_stun() # Kết thúc choáng, nhưng thanh Sin vẫn neo ở mức 100!
		enemy_stun_skipped.emit()
		return
		
	# 2. Nếu Boss không bị Choáng (hoặc đã hết choáng từ lượt trước) -> Tấn công người chơi!
	var is_heavy = randf() < 0.4
	var raw_dmg = 32 if is_heavy else 20
	var attack_name = "Thiết Bổng Nghiền Nát" if is_heavy else "Chùm Chìa Khóa Gai Quất"
	
	enemy_attack_triggered.emit(attack_name, raw_dmg, is_heavy)

func apply_enemy_attack(raw_dmg: int, is_heavy: bool) -> Dictionary:
	var dmg_data = DamageData.new(raw_dmg, 0, false, is_heavy, "Kẻ Cai Ngục")
	var result = player.take_hit(dmg_data)
	
	screen_shake_requested.emit(10.0 if is_heavy else 6.0)
	
	if player.is_dead:
		state = GlobalEnums.BattleState.DEFEAT
		state_changed.emit(state)
	else:
		_end_round()
		
	return result

func _end_round() -> void:
	round_count += 1
	state = GlobalEnums.BattleState.PLAYER_TURN
	state_changed.emit(state)
