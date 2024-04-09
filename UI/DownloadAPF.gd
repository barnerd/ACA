extends Button

var thread: Thread = Thread.new()
var file_to_download: Image = Image.new()


func _init() -> void:
	pass #self.disabled = true


func _ready() -> void:
	pass
	#thread.start(prepare_file, Thread.PRIORITY_LOW)


func _on_pressed() -> void:
	# put conversion code here for now
	# terrain types need to change as well
	for type in MapDetailsSingleton.terrain_details:
		type.terrain_id = MapDetailsSingleton.terrain_id_from_apf_to_internal[type.terrain_id]

	# run through all map tiles
	for tile in MapDetailsSingleton.map_tiles:
		tile.terrain_id = MapDetailsSingleton.terrain_id_from_apf_to_internal[tile.terrain_id]
		tile.terrain_details = MapDetailsSingleton.terrains_by_id[tile.terrain_id]

	# run through all sprite tiles
	var tile_set_source = MapDetailsSingleton.tile_map_display.tile_set.get_source(0)
	for index in tile_set_source.get_tiles_count():
		var tileset_coords = tile_set_source.get_tile_id(index)
	
		var old_terrain_id = tile_set_source.get_tile_data(tileset_coords).get_custom_data("terrain_id")
		var new_terrain_id = MapDetailsSingleton.terrain_id_from_apf_to_internal[old_terrain_id]
		tile_set_source.get_tile_data(tileset_coords).set_custom_data("terrain_id", new_terrain_id)
	#download_file(file_to_download, "agoniaMap2")


func on_processing_done():
	pass #self.disabled = false


func prepare_file() -> void:
	
	
	call_deferred("on_processing_done")


func download_file(_file: Image, _filename: String):
	print("Downloading image " + _filename + ".txt")
	var buffer = _file.save_png_to_buffer()
	JavaScriptBridge.download_buffer(buffer, "%s.txt" % _filename, "text/plain")


func _exit_tree():
	thread.wait_to_finish()
