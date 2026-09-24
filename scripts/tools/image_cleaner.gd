@tool
extends SceneTree

func _init() -> void:
	print("--- Running Image Cleaner ---")
	_clean_chained_sinner()
	_clean_blighted_hound()
	quit()

func _clean_chained_sinner() -> void:
	var path_in = "res://Image SRC/02_05_chained_sinner.png"
	var path_out = "res://Image SRC/chained_sinner_clean.png"
	var img = Image.load_from_file(path_in)
	if not img:
		return
	var w = img.get_width()
	var h = img.get_height()
	var bg_color = Color(14.0/255.0, 13.0/255.0, 13.0/255.0, 1.0)
	for y in range(0, int(h * 0.16)):
		for x in range(0, int(w * 0.75)):
			img.set_pixel(x, y, bg_color)
	img.save_png(path_out)

func _clean_blighted_hound() -> void:
	var path_in = "res://Image SRC/02_06_blighted_hound.png"
	var path_out = "res://Image SRC/blighted_hound_clean.png"
	var img = Image.load_from_file(path_in)
	if not img:
		return
	var w = img.get_width()
	var h = img.get_height()
	var bg_color = Color(14.0/255.0, 13.0/255.0, 13.0/255.0, 1.0)
	for y in range(0, int(h * 0.16)):
		for x in range(0, int(w * 0.65)):
			img.set_pixel(x, y, bg_color)
	img.save_png(path_out)
	print("Saved clean blighted hound to: ", path_out)
