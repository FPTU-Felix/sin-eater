@tool
extends SceneTree

func _init() -> void:
	var files = [
		"res://Image SRC/02_01_penitent_knight.png",
		"res://Image SRC/02_03_sir_gervaise_weeping_jailer.png",
		"res://Image SRC/04_01_basic_slash.png"
	]
	for path in files:
		var img = Image.new()
		var err = img.load(path)
		if err == OK:
			print("=== ", path, " (", img.get_width(), "x", img.get_height(), ") ===")
			print("  Format: ", img.get_format(), " Has alpha? ", img.detect_alpha())
			print("  Top-Left (0,0): ", img.get_pixel(0, 0))
			print("  Top-Right: ", img.get_pixel(img.get_width() - 1, 0))
			print("  Bottom-Left: ", img.get_pixel(0, img.get_height() - 1))
			print("  Sample (10,10): ", img.get_pixel(10, 10))
		else:
			print("Error loading: ", path)
	quit(0)
