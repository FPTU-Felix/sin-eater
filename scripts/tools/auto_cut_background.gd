@tool
extends SceneTree

func _init() -> void:
	print("--- TỰ ĐỘNG CẮT NỀN ẢNH (AUTO BACKGROUND CUTOUT) ---")
	var targets = [
		"res://Image SRC/02_01_penitent_knight.png",
		"res://Image SRC/The penitent.png",
		"res://Image SRC/02_03_sir_gervaise_weeping_jailer.png"
	]
	
	for path in targets:
		cut_background(path)
	
	quit(0)

func cut_background(img_path: String) -> void:
	var img = Image.new()
	var err = img.load(img_path)
	if err != OK:
		print("Lỗi đọc file: ", img_path)
		return
		
	img.convert(Image.FORMAT_RGBA8)
	var w = img.get_width()
	var h = img.get_height()
	
	# Sample corner color as base background
	var c_tl = img.get_pixel(0, 0)
	var c_tr = img.get_pixel(w - 1, 0)
	var c_bl = img.get_pixel(0, h - 1)
	var c_br = img.get_pixel(w - 1, h - 1)
	
	print("Processing: ", img_path, " [", w, "x", h, "]")
	print("Corner colors: TL=", c_tl, " TR=", c_tr)
	
	# Flood fill from all 4 borders to remove contiguous dark background
	var visited = []
	for y in range(h):
		var row = []
		row.resize(w)
		row.fill(false)
		visited.append(row)
		
	var queue: Array[Vector2i] = []
	# Seed border pixels
	for x in range(w):
		queue.append(Vector2i(x, 0))
		queue.append(Vector2i(x, h - 1))
	for y in range(h):
		queue.append(Vector2i(0, y))
		queue.append(Vector2i(w - 1, y))
		
	var removed_count = 0
	
	# Tolerance for dark background:
	# Check luminance and distance to dark tones
	while queue.size() > 0:
		var pt = queue.pop_front()
		var px = pt.x
		var py = pt.y
		
		if px < 0 or px >= w or py < 0 or py >= h:
			continue
		if visited[py][px]:
			continue
		visited[py][px] = true
		
		var col = img.get_pixel(px, py)
		var lum = col.r * 0.299 + col.g * 0.587 + col.b * 0.114
		
		# If the pixel is dark background (lum < 0.15 and not vibrant saturated color)
		var max_channel = max(col.r, max(col.g, col.b))
		var min_channel = min(col.r, min(col.g, col.b))
		var saturation = (max_channel - min_channel) if max_channel > 0.0 else 0.0
		
		var is_bg = false
		if lum < 0.13:
			is_bg = true
		elif lum < 0.22 and saturation < 0.10: # near neutral dark gray
			is_bg = true
			
		if is_bg:
			# Soft feathering at the outer edge
			img.set_pixel(px, py, Color(0, 0, 0, 0))
			removed_count += 1
			
			# Expand 4 directions
			queue.append(Vector2i(px + 1, py))
			queue.append(Vector2i(px - 1, py))
			queue.append(Vector2i(px, py + 1))
			queue.append(Vector2i(px, py - 1))

	# Save output
	var save_err = img.save_png(img_path)
	print("Đã cắt nền: ", img_path, " -> Bỏ ", removed_count, " pixels nền. Kết quả lưu: ", save_err == OK)
