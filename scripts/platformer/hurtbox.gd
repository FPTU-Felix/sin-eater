class_name Hurtbox
extends Area2D

# ==============================================================================
# 🛡️ HURTBOX LÀ GÌ?
# Hurtbox là "vùng da thịt nhận đòn".
# Cả Hiệp Sĩ, Quái Vật và các Bình Cổ có thể vỡ đều gắn một Hurtbox.
# Khi có một Hitbox chạm vào, Hurtbox sẽ rung chuông tín hiệu "hit_received"!
# ==============================================================================

enum HurtboxType {
	ENEMY_OR_PROP,  # Quái vật / Đồ vật nhận sát thương từ người chơi
	PLAYER          # Người chơi nhận sát thương từ quái vật
}

signal hit_received(hitbox: Hitbox)

@export var hurtbox_type: HurtboxType = HurtboxType.ENEMY_OR_PROP
@export var is_invincible: bool = false # Khi bật cờ này (như lúc đang lướt Dash), quái chém không trúng!

func _ready() -> void:
	monitoring = true
	monitorable = true
	_apply_collision_layers()
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _apply_collision_layers() -> void:
	if hurtbox_type == HurtboxType.PLAYER:
		collision_layer = 64  # Layer 7: Player Hurtbox
		collision_mask = 32   # Layer 6: Enemy Hitbox
	else:
		collision_layer = 16  # Layer 5: Enemy/Prop Hurtbox
		collision_mask = 8    # Layer 4: Player Hitbox

func _on_area_entered(area: Area2D) -> void:
	if is_invincible:
		return
		
	if area is Hitbox:
		hit_received.emit(area)
