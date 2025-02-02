extends Button

var tile_size:int = 24

var thread: Thread = Thread.new()
var need_to_stop: bool = false

var image_to_download = preload("res://Flat Files/agonia_map.png")
var is_preparing: bool = false

signal downloadable_file_progress(progress: float)


#func _init() -> void:
	#self.text = "Prepare Map Image"
	##self.disabled = false
#
#
#func _ready() -> void:
	#pass #SignalBus.connect_to_signal("savefile_loaded", prepare_image_on_thread)


func _on_pressed() -> void:
	# for use with viewports
	#image_to_download = portport.get_texture().get_image()
	
	#if not is_preparing:
		#is_preparing = true
		#self.disabled = true
		#thread.start(prepare_image, Thread.PRIORITY_LOW)
	#else:
	download_image(image_to_download.get_image(), "agonia_map")


#func on_processing_done():
	#self.disabled = false
#
#
#func prepare_image_on_thread() -> void:
	#thread.start(prepare_image, Thread.PRIORITY_LOW)


#func prepare_image() -> void:
	#print("preparing map image file")
	## start with Terrain_Colors image
	##image_to_download.resize(8400, 8400, Image.INTERPOLATE_NEAREST)
	#image_to_download.copy_from(AgoniaData.MapData.terrain_colors_display.texture.get_image())
	#image_to_download.convert(Image.Format.FORMAT_RGBA8)
	#
	#var tile_map = AgoniaData.MapData.tile_map_display
	#var tile_set = tile_map.tile_set
	#
	## generate AtlasTexture form TileSet sources
	#var atlas_texture: Dictionary = {}
	#for source in tile_set.get_source_count():
		#atlas_texture[source] = AtlasTexture.new()
		#atlas_texture[source].atlas = tile_set.get_source(tile_set.get_source_id(source)).texture
	#
	#var sprite_texture: ImageTexture = ImageTexture.create_from_image(Image.create(tile_size, tile_size, false, Image.FORMAT_RGBA8))
	#
	#var cells_processed: int = 0
	#var total_cells: int = 0
	#for i in tile_map.get_layers_count():
		#if tile_map.is_layer_enabled(i):
			## Get active cells per layer of TileMap
			#total_cells += tile_map.get_used_cells(i).size()
	#
	#for i in tile_map.get_layers_count():
		#if tile_map.is_layer_enabled(i):
			## Get active cells per layer of TileMap
			#var used_cells = tile_map.get_used_cells(i)
			#
			## from: https://www.reddit.com/r/godot/comments/15pv3lt/comment/k8ovwv7/?context=3
			## for each cell, paint TileMap sprite on image
			#for cell_coords in used_cells:
				#if need_to_stop:
					#print("terminating thread")
					#call_deferred("quit_thread")
					#return
				#
				## create atlas from source
				#var tile_source = tile_map.get_cell_source_id(i, cell_coords)
				#
				## find region on atlas for this cell
				#var tile_atlas_coords = tile_map.get_cell_atlas_coords(i, cell_coords)
				#var region = Rect2i(tile_atlas_coords * tile_size, Vector2i.ONE * tile_size)
				#
				## get sprite for cell
				#sprite_texture.update(atlas_texture[tile_source].atlas.get_image().get_region(region))
				#
				##print("painting cell onto " + str(cell_coords))
				## paint cell spirte on image
				## void blit_rect ( Image src, Rect2i src_rect, Vector2i dst )
				#image_to_download.blit_rect(sprite_texture.get_image(), Rect2i(Vector2i.ZERO, Vector2i.ONE * tile_size), cell_coords * tile_size)
				#
				#cells_processed += 1
				##print("progress: " + str(100.0 * cells_processed / total_cells) + "%")
				#call_deferred("_on_downloadable_file_progress", 100.0 * cells_processed / total_cells)
	#
	#print("finished preparing map image file")
	#call_deferred("on_processing_done")


func download_image(_img: Image, _filename: String):
	print("Downloading image " + _filename + ".png")
	var buffer = _img.save_png_to_buffer()
	JavaScriptBridge.download_buffer(buffer, "%s.png" % _filename, "image/png")


#func _exit_tree():
	#if thread.is_started():
		#need_to_stop = true
		##thread.wait_to_finish()
#
#
#func quit_thread():
	#thread.wait_to_finish()
#
#
#func _on_downloadable_file_progress(_progress: float) -> void:
	##print("Preparing - %0.2f%%" % _progress)
	#self.text = "Preparing - %0.2f%%" % _progress
