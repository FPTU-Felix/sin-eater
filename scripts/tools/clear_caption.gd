@tool
extends SceneTree

func _init() -> void:
	var path = "res://Image SRC/02_01_penitent_knight.png"
	var img = Image.new()
	img.load(path)
	
	# The text is in the top ~40 pixels on the left.
	# Fill y from 0 to 45 with background color (0.051, 0.0549, 0.0588)
	var bg_col = img.get_pixel(0, 0)
	print("Clearing caption text in top 45 rows with color: ", bg_col)
	for y in range(48):
		for x in range(img.get_width()):
			img.set_pixel(x, y, bg_col)
			
	img.save_png("res://Image SRC/02_01_penitent_knight.png")
	img.save_png("res://Image SRC/The penitent.png")
	print("Done removing text caption!")
	quit(0)
