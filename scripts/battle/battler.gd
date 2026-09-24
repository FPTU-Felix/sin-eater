class_name Battler
extends Node

signal blood_changed(current: int, max_val: int)
signal guilt_changed(current: int, max_val: int)
signal sin_changed(current: int, max_val: int)
signal stunned_state_changed(is_stunned: bool)
signal died()

var faction: GlobalEnums.Faction = GlobalEnums.Faction.PLAYER
var stats: BattlerStats

var current_blood: int = 100
var current_guilt: int = 0
var current_sin: int = 0
var is_stunned: bool = false
var is_dead: bool = false
var stun_triggered_for_current_max: bool = false

func setup(p_stats: BattlerStats, p_faction: GlobalEnums.Faction) -> void:
	stats = p_stats
	faction = p_faction
	is_dead = false
	is_stunned = false
	stun_triggered_for_current_max = false
	
	if faction == GlobalEnums.Faction.PLAYER:
		current_blood = stats.max_vessel
		current_guilt = 0
		current_sin = 0
		blood_changed.emit(current_blood, stats.max_vessel)
		guilt_changed.emit(current_guilt, stats.max_vessel)
	else:
		current_blood = stats.max_blood
		current_guilt = 0
		current_sin = 0
		blood_changed.emit(current_blood, stats.max_blood)
		sin_changed.emit(current_sin, stats.max_sin)
		stunned_state_changed.emit(false)

func take_hit(damage: DamageData) -> Dictionary:
	var result = {
		"actual_blood_damage": 0,
		"sin_inflicted": 0,
		"caused_stun": false,
		"is_dead": false
	}
	
	if is_dead:
		return result
		
	var effective_damage = max(1, int(float(damage.blood_damage) * (1.0 - stats.armor_percent)))
	
	if faction == GlobalEnums.Faction.PLAYER:
		# Player: Máu giảm -> Tội Lỗi (Guilt) tăng tương ứng
		var actual_dmg = min(current_blood, effective_damage)
		current_blood -= actual_dmg
		current_guilt = min(stats.max_vessel - current_blood, current_guilt + actual_dmg)
		result["actual_blood_damage"] = actual_dmg
		
		blood_changed.emit(current_blood, stats.max_vessel)
		guilt_changed.emit(current_guilt, stats.max_vessel)
		
		if current_blood <= 0:
			is_dead = true
			result["is_dead"] = true
			died.emit()
	else:
		# Enemy: Máu giảm -> Nghiệp Tội (Sin) tăng
		var actual_dmg = min(current_blood, effective_damage)
		current_blood -= actual_dmg
		result["actual_blood_damage"] = actual_dmg
		
		if damage.is_verdict:
			# Đòn Trừng Phạt (Verdict): Tiêu hao toàn bộ Sin về 0 và xóa trạng thái choáng
			current_sin = 0
			stun_triggered_for_current_max = false
			is_stunned = false
			stunned_state_changed.emit(false)
		else:
			var prev_sin = current_sin
			current_sin = min(stats.max_sin, current_sin + damage.sin_damage)
			result["sin_inflicted"] = current_sin - prev_sin
			
			# Chỉ kích hoạt CHOÁNG ở lượt đầu tiên khi Sin vừa chạm mốc tối đa
			if current_sin >= stats.max_sin and not stun_triggered_for_current_max:
				stun_triggered_for_current_max = true
				is_stunned = true
				result["caused_stun"] = true
				stunned_state_changed.emit(true)
				
		blood_changed.emit(current_blood, stats.max_blood)
		sin_changed.emit(current_sin, stats.max_sin)
		
		if current_blood <= 0:
			is_dead = true
			result["is_dead"] = true
			died.emit()
			
	return result

func sacrifice_blood(amount: int) -> int:
	if faction != GlobalEnums.Faction.PLAYER or is_dead:
		return 0
	var actual = min(amount, current_blood - 1)
	if actual > 0:
		current_blood -= actual
		current_guilt = min(stats.max_vessel - current_blood, current_guilt + actual)
		blood_changed.emit(current_blood, stats.max_vessel)
		guilt_changed.emit(current_guilt, stats.max_vessel)
	return actual

func perform_atonement() -> int:
	if faction != GlobalEnums.Faction.PLAYER or is_dead:
		return 0
	var restored = current_guilt
	current_blood += restored
	current_guilt = 0
	blood_changed.emit(current_blood, stats.max_vessel)
	guilt_changed.emit(current_guilt, stats.max_vessel)
	return restored

func get_guilt_multiplier() -> float:
	if faction != GlobalEnums.Faction.PLAYER:
		return 1.0
	var ratio = float(current_guilt) / float(max(1, stats.max_vessel))
	return 1.0 + (ratio * stats.guilt_scaling)

func recover_from_stun() -> void:
	if is_stunned:
		is_stunned = false
		stunned_state_changed.emit(false)
		# LƯU Ý: Thanh Sin VẪN GIỮ NGUYÊN Ở MỨC TỐI ĐA (100) để người chơi có thể Trừng Phạt bất cứ lúc nào!
