class_name Hitbox
extends Area2D

# ==============================================================================
# ⚔️ HITBOX LÀ GÌ?
# Hitbox là "lưỡi kiếm / vùng gây sát thương".
# Khi bạn vung kiếm hoặc quái vật vung xích, Hitbox này sẽ bật lên.
# Bất kỳ ai có Hurtbox chạm vào Hitbox này đều sẽ bị mất máu và nhận điểm Sin!
# ==============================================================================

enum HitboxType {
	PLAYER,  # Đòn đánh của người chơi -> Đánh trúng quái vật / thùng gỗ
	ENEMY    # Đòn đánh của quái vật -> Đánh trúng người chơi
}

@export var hitbox_type: HitboxType = HitboxType.PLAYER
@export var damage: int = 20           # Sát thương gây ra cho kẻ địch
@export var sin_inflict: int = 15      # Lượng điểm Sin nhồi cho kẻ địch
@export var knockback_force: float = 120.0 # Lực đẩy lùi kẻ địch khi trúng đòn
@export var is_verdict: bool = false   # Cờ đánh dấu đây có phải đòn Trừng Phạt chí mạng không

var source_attacker: Node2D = null

func _ready() -> void:
	monitoring = true
	monitorable = true
	_apply_collision_layers()

func _apply_collision_layers() -> void:
	if hitbox_type == HitboxType.PLAYER:
		collision_layer = 8   # Layer 4: Player Hitbox
		collision_mask = 16   # Layer 5: Enemy/Prop Hurtbox
	else:
		collision_layer = 32  # Layer 6: Enemy Hitbox
		collision_mask = 64   # Layer 7: Player Hurtbox
