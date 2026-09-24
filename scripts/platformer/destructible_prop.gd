class_name DestructibleProp
extends Node2D

# ==============================================================================
# 🏺 VẬT THỂ CÓ THỂ BỊ CHÉM VỠ (Bình Cổ, Hình Nhân Luyện Kiếm, Hài Cốt)
# Gắn Hurtbox để nhận sát thương từ Hitbox của người chơi!
# ==============================================================================

@export var max_health: int = 60
@export var prop_name: String = "Bình Hài Cốt Cổ"

var current_health: int = 60
var is_broken: bool = false

@onready var hurtbox: Hurtbox = $Hurtbox
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var label: Label = get_node_or_null("Label")

func _ready() -> void:
	current_health = max_health
	hurtbox.hit_received.connect(_on_hit_received)
	_update_label()

func _on_hit_received(incoming_hitbox: Hitbox) -> void:
	if is_broken:
		return
		
	var dmg = incoming_hitbox.damage
	current_health = max(0, current_health - dmg)
	
	# Chớp trắng báo hiệu bị chém trúng
	var t = create_tween()
	modulate = Color(3.0, 3.0, 3.0)
	t.tween_property(self, "modulate", Color.WHITE, 0.12)
	
	# Nhảy nhẹ lên khi bị chém
	position.y -= 6.0
	var recoil_tween = create_tween()
	recoil_tween.tween_property(self, "position:y", position.y + 6.0, 0.15).set_trans(Tween.TRANS_BOUNCE)
	
	_update_label()
	
	if current_health <= 0:
		_destroy()

func _update_label() -> void:
	if label:
		label.text = "%s\n[%d / %d]" % [prop_name, current_health, max_health]

func _destroy() -> void:
	is_broken = true
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	
	if label:
		label.text = "💥 ĐÃ BỊ CHÉM NÁT!"
		label.modulate = Color(1.0, 0.4, 0.4)
		
	var t = create_tween()
	t.tween_property(self, "scale", Vector2(1.2, 0.1), 0.2)
	t.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	t.tween_callback(queue_free)
