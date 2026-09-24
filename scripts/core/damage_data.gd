class_name DamageData
extends RefCounted

var blood_damage: int = 0
var sin_damage: int = 0
var is_verdict: bool = false
var is_critical: bool = false
var attacker_name: String = ""

func _init(p_blood: int = 0, p_sin: int = 0, p_verdict: bool = false, p_crit: bool = false, p_attacker: String = ""):
	blood_damage = p_blood
	sin_damage = p_sin
	is_verdict = p_verdict
	is_critical = p_crit
	attacker_name = p_attacker
