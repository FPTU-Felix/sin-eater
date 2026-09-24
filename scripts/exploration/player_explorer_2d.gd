class_name PlayerExplorer2D
extends CharacterBody2D

const SPEED: float = 260.0
const JUMP_VELOCITY: float = -420.0
const SPRITE_BASE_Y: float = -75.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D

var gravity: float = 980.0
var walk_cycle: float = 0.0
var idle_cycle: float = 0.0
var prev_jump_down: bool = false

func _ready() -> void:
	if GameManager.has_saved_pos:
		global_position = GameManager.player_exploration_pos
	sprite.position.y = SPRITE_BASE_Y

func _physics_process(delta: float) -> void:
	# 1. Trọng lực (Gravity)
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# 2. Xử lý Phím Nhảy (Hỗ trợ cả SPACE, W, Mũi Tên Lên, Controller)
	var jump_down: bool = (
		Input.is_physical_key_pressed(KEY_SPACE)
		or Input.is_physical_key_pressed(KEY_W)
		or Input.is_physical_key_pressed(KEY_UP)
		or Input.is_action_pressed("ui_accept")
		or Input.is_action_pressed("ui_up")
	)
	var jump_just_pressed: bool = jump_down and not prev_jump_down
	prev_jump_down = jump_down

	if jump_just_pressed and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Xử lý Phím Đi Ngang (Hỗ trợ A, D, Mũi Tên Trái/Phải, Controller)
	var direction: float = 0.0
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT) or Input.is_action_pressed("ui_left"):
		direction -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT) or Input.is_action_pressed("ui_right"):
		direction += 1.0

	if direction != 0.0:
		velocity.x = direction * SPEED
		sprite.flip_h = (direction < 0.0)
		
		# Nhấp nhô nhịp bước chân Dark Fantasy (Neo đúng vị trí -75px)
		walk_cycle += delta * 14.0
		sprite.position.y = SPRITE_BASE_Y + sin(walk_cycle) * 3.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 8.0 * delta)
		
		# Nhịp thở trang nghiêm khi đứng yên
		idle_cycle += delta * 2.5
		sprite.position.y = SPRITE_BASE_Y + sin(idle_cycle) * 2.0

	move_and_slide()
