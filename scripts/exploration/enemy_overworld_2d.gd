class_name EnemyOverworld2D
extends Area2D

@export var enemy_id: String = "boss_jailer"
@export var patrol_distance: float = 120.0
@export var patrol_speed: float = 40.0

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

var start_x: float = 0.0
var direction: float = -1.0
var is_triggered: bool = false

func _ready() -> void:
	# Nếu quái đã bị đánh bại trước đó -> Biến mất khỏi bản đồ
	if GameManager.defeated_enemies.has(enemy_id):
		queue_free()
		return
		
	start_x = position.x
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if is_triggered:
		return
		
	# Tuần tra qua lại
	position.x += direction * patrol_speed * delta
	if abs(position.x - start_x) >= patrol_distance:
		direction *= -1.0
		if sprite:
			sprite.flip_h = (direction > 0.0)

func _on_body_entered(body: Node2D) -> void:
	if is_triggered:
		return
		
	if body is PlayerExplorer2D:
		is_triggered = true
		# Dùng call_deferred để không kích hoạt đổi scene giữa lúc physics callback đang chạy
		GameManager.call_deferred("start_battle", enemy_id, body.global_position)
