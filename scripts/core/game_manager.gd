extends Node

func _ready() -> void:
	print(">>> [GameManager] Autoload initialized successfully!")

var player_exploration_pos: Vector2 = Vector2(200, 520)
var has_saved_pos: bool = false
var defeated_enemies: Array[String] = []
var current_enemy_id: String = ""

func start_battle(enemy_id: String, player_pos: Vector2) -> void:
	current_enemy_id = enemy_id
	player_exploration_pos = player_pos
	has_saved_pos = true
	# Dùng call_deferred để tránh lỗi xóa CollisionObject trong physics callback
	get_tree().call_deferred("change_scene_to_file", "res://battle_screen.tscn")

func finish_battle(victory: bool) -> void:
	if victory and not current_enemy_id.is_empty():
		if not defeated_enemies.has(current_enemy_id):
			defeated_enemies.append(current_enemy_id)
			
	current_enemy_id = ""
	get_tree().call_deferred("change_scene_to_file", "res://scenes/exploration/catacomb_hallway.tscn")

func reset_progress() -> void:
	defeated_enemies.clear()
	has_saved_pos = false
	player_exploration_pos = Vector2(200, 520)
