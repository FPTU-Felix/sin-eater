class_name PlayerHUD
extends CanvasLayer

@onready var blood_bar: ProgressBar = $Panel/HBox/VBox/BloodBar
@onready var blood_label: Label = $Panel/HBox/VBox/BloodBar/Label
@onready var guilt_bar: ProgressBar = $Panel/HBox/VBox/GuiltBar
@onready var guilt_label: Label = $Panel/HBox/VBox/GuiltBar/Label
@onready var frenzy_label: Label = $Panel/HBox/VBox/FrenzyLabel

var player: PlayerKnight = null

func setup(p_player: PlayerKnight) -> void:
	player = p_player
	player.blood_changed.connect(_on_blood_changed)
	player.guilt_changed.connect(_on_guilt_changed)
	player.frenzy_changed.connect(_on_frenzy_changed)
	
	_on_blood_changed(player.current_blood, player.max_vessel)
	_on_guilt_changed(player.current_guilt, player.max_vessel)
	_on_frenzy_changed(player.get_guilt_multiplier())

func _on_blood_changed(current: int, max_val: int) -> void:
	blood_bar.max_value = max_val
	blood_bar.value = current
	blood_label.text = "MÁU: %d / %d" % [current, max_val]

func _on_guilt_changed(current: int, max_val: int) -> void:
	guilt_bar.max_value = max_val
	guilt_bar.value = current
	guilt_label.text = "TỘI LỖI: %d / %d" % [current, max_val]

func _on_frenzy_changed(multiplier: float) -> void:
	var bonus_pct = int((multiplier - 1.0) * 100.0)
	if bonus_pct > 0:
		frenzy_label.text = "🔥 CUỒNG TỘI: +%d%% SÁT THƯƠNG!" % bonus_pct
		frenzy_label.modulate = Color(1.0, 0.35, 0.35)
	else:
		frenzy_label.text = "CUỒNG TỘI: +0% SÁT THƯƠNG"
		frenzy_label.modulate = Color(0.7, 0.7, 0.7)
