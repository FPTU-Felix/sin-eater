@tool
extends SceneTree

func _init() -> void:
	var knight_ctex = load("res://.godot/imported/02_01_penitent_knight.png-edcef5a3c868bb217c93cfa607652fb8.ctex")
	if knight_ctex:
		var img = knight_ctex.get_image()
		img.save_png("res://Image SRC/02_01_penitent_knight.png")
		img.save_png("res://Image SRC/The penitent.png")
		print("Restored original penitent knight from ctex!")
		
	var boss_ctex = load("res://.godot/imported/02_03_sir_gervaise_weeping_jailer.png-00d4077c9647e286225223d408f0d42a.ctex")
	if boss_ctex:
		var img = boss_ctex.get_image()
		img.save_png("res://Image SRC/02_03_sir_gervaise_weeping_jailer.png")
		print("Restored original boss from ctex!")
		
	quit(0)
