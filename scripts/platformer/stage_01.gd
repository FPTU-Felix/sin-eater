extends Node2D

@onready var player: PlayerKnight = $PlayerKnight
@onready var hud: PlayerHUD = $PlayerHUD

func _ready() -> void:
	if player and hud:
		hud.setup(player)
		print(">>> [Stage01] Player Knight & HUD connected successfully!")
