extends Button

var tile_size:int = 24

var thread: Thread = Thread.new()
var image_to_download: Image = Image.new()
@onready var portport = $/root/Node2D/Control/PanelContainer/ScrollContainer/Control/HBoxContainer/SubViewportContainer/SubViewport


func _init() -> void:
	self.disabled = true


func _ready() -> void:
	pass
	#thread.start(prepare_image, Thread.PRIORITY_LOW)


func _on_pressed() -> void:
	image_to_download = portport.get_texture().get_image()
	download_image(image_to_download, "agonia_map")


func on_processing_done():
	pass #self.disabled = false


func prepare_image() -> void:
	# start with Terrain_Colors image
	#image_to_download.resize(8400, 8400, Image.INTERPOLATE_NEAREST)
	image_to_download.copy_from(MapDetailsSingleton.terrain_colors_display.texture.get_image())
	image_to_download.convert(Image.Format.FORMAT_RGBA8)
	
	var tile_map = MapDetailsSingleton.tile_map_display
	var tile_set = tile_map.tile_set
	
	# generate AtlasTexture form TileSet sources
	var atlas_texture: Dictionary = {}
	for source in tile_set.get_source_count():
		atlas_texture[source] = AtlasTexture.new()
		atlas_texture[source].atlas = tile_set.get_source(tile_set.get_source_id(source)).texture
	
	
	
	var sprite_texture: ImageTexture = ImageTexture.create_from_image(Image.create(tile_size, tile_size, false, Image.FORMAT_RGBA8))
	
	var cells_processed: int = 0
	var total_cells: int = 0
	for i in tile_map.get_layers_count():
		if tile_map.is_layer_enabled(i) and not i == 0:
			# Get active cells per layer of TileMap
			total_cells += tile_map.get_used_cells(i).size()
	
	for i in tile_map.get_layers_count():
		if tile_map.is_layer_enabled(i) and not i == 0:
			# Get active cells per layer of TileMap
			var used_cells = tile_map.get_used_cells(i)
			
			# from: https://www.reddit.com/r/godot/comments/15pv3lt/comment/k8ovwv7/?context=3
			# for each cell, paint TileMap sprite on image
			for cell_coords in used_cells:
				# create atlas from source
				var tile_source = tile_map.get_cell_source_id(i, cell_coords)
				
				# find region on atlas for this cell
				var tile_atlas_coords = tile_map.get_cell_atlas_coords(i, cell_coords)
				var region = Rect2i(tile_atlas_coords * tile_size, Vector2i.ONE * tile_size)
				
				# get sprite for cell
				sprite_texture.update(atlas_texture[tile_source].atlas.get_image().get_region(region))
				
				#print("painting cell onto " + str(cell_coords))
				# paint cell spirte on image
				# void blit_rect ( Image src, Rect2i src_rect, Vector2i dst )
				image_to_download.blit_rect(sprite_texture.get_image(), Rect2i(Vector2i.ZERO, Vector2i.ONE * tile_size), cell_coords * tile_size)
				
				cells_processed += 1
				print("progress: " + str(100.0 * cells_processed / total_cells) + "%")
	
	call_deferred("on_processing_done")


func paint_tile(_position: Vector2i, _color: Color) -> void:
	var rect_size = tile_size - 1
	var tile: Rect2i = Rect2i(_position.x * tile_size, _position.y * tile_size, rect_size, rect_size)
	
	var display_image
	display_image.fill_rect(tile, _color)


func download_image(_img: Image, _filename: String):
	print("Downloading image " + _filename + ".png")
	var buffer = _img.save_png_to_buffer()
	JavaScriptBridge.download_buffer(buffer, "%s.png" % _filename, "image/png")


func _exit_tree():
	thread.wait_to_finish()
