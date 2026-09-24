class_name InteractableDoor2D
extends Area2D

@export var required_enemy_id: String = "boss_jailer"

@onready var prompt_label: Label = $PromptLabel
@onready var status_label: Label = $StatusLabel

var is_player_inside: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt_label.visible = false
	status_label.visible = false

func _process(_delta: float) -> void:
	if not is_player_inside:
		return
		
	var is_boss_dead = GameManager.defeated_enemies.has(required_enemy_id)
	
	if is_boss_dead:
		prompt_label.text = "✨ [ NHẤN E HOẶC ENTER ]: MỞ CỬA BƯỚC SANG TẦNG 2"
		prompt_label.modulate = Color(1.0, 0.85, 0.3)
		if Input.is_physical_key_pressed(KEY_E) or Input.is_action_just_pressed("ui_accept"):
			status_label.visible = true
			status_label.text = "🏆 BẠN ĐÃ CHINH PHỤC TẦNG 1: HẦM MỘ GÔNG XIỀNG!\n(Bản Demo Hoàn Thành Xuất Sắc!)"
	else:
		prompt_label.text = "🔒 CỬA ĐÃ BỊ KHÓA! Hãy tiêu diệt Kẻ Cai Ngục Khóc Máu!"
		prompt_label.modulate = Color(0.9, 0.3, 0.3)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerExplorer2D:
		is_player_inside = true
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body is PlayerExplorer2D:
		is_player_inside = false
		prompt_label.visible = false
		status_label.visible = false
