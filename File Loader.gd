extends Node

var apf_flat_filename: String = "res://Flat Files/agoniaMap2.txt"

signal savefile_loaded


func _init() -> void:
	SignalBus.register_signal("savefile_loaded", savefile_loaded)


func _ready() -> void:
	#var agoniaMap:String = load_file(apf_flat_filename)
	#parse_map_file(agoniaMap)
	load_game()
	
	#$"../Control/PanelContainer/ScrollContainer/Control/HBoxContainer/PanelContainer/TerrainColors".apply_image()
	#tile_map_display.visible = false
	
	#var print_coords = Vector3i(275, 170, 0)
	#print("location: " + str(map_tiles[print_coords].location))
	#print("image : map-" + str(map_tiles[print_coords].tile_image_id))
	#print("terrain: " + str(map_tiles[print_coords].terrain_id))
	#print("terrain name: " + str(map_tiles[print_coords].terrain_details.terrain_name))
	#print("terrain details id: " + str(map_tiles[print_coords].terrain_details.terrain_id))
	#print("terrain color: " + str(map_tiles[print_coords].terrain_details.terrain_color_default))
	#print("terrain kiith mvp: " + str(map_tiles[print_coords].terrain_details.kiith_mvp))
	#print("encounter table: " + str(map_tiles[print_coords].encounter_table_id))


func _input(event) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_S:
			if event.meta_pressed:
				print("Cmd-S was pressed")
				save_game()


func load_file(_filename: String) -> String:
	var content: String = ""
	var file = FileAccess.open(_filename, FileAccess.READ)
	if file:
		content = file.get_as_text()
	return content


# From Godot Docs: https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
# Note: This can be called from anywhere inside the tree. This function is
# path independent.
# Go through everything in the persist category and ask them to return a
# dict of relevant variables.
func save_game() -> void:
	print("saving game...")
	var save_game_file = FileAccess.open("res://savegame.txt", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			#continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_game_file.store_line(json_string)


# From Godot Docs: https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():
	print("loading game...")
	# TODO: save this to tileset after runtime
	print("Convert TileSet to Internal terrain_ids")
	var tile_set_source = MapDetailsSingleton.tile_map_display.tile_set.get_source(0)
	for index in tile_set_source.get_tiles_count():
		var tileset_coords = tile_set_source.get_tile_id(index)
		var tile_data = tile_set_source.get_tile_data(tileset_coords, 0)

		var old_terrain_id = tile_data.get_custom_data("terrain_id")
		if not old_terrain_id == -1:
			var new_terrain_id = MapDetailsSingleton.terrain_id_from_apf_to_internal[old_terrain_id]
			tile_data.set_custom_data("terrain_id", new_terrain_id)
			
			#print({"old_id": old_terrain_id, "new_id": new_terrain_id, "tile_data": tile_data.get_custom_data("terrain_id")})
	
	print("loading file...")
	if not FileAccess.file_exists("res://savegame.txt"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	#var save_nodes = get_tree().get_nodes_in_group("Persist")
	#for i in save_nodes:
	#	i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_game_file = FileAccess.open("res://savegame.txt", FileAccess.READ)
	while save_game_file.get_position() < save_game_file.get_length():
		var json_string = save_game_file.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		# Firstly, we need to create the object and add it to the tree and set its position.
		#var loaded_object = load(node_data["filename"]).instantiate()
		#get_node(node_data["parent"]).add_child(new_object)
		#new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		var loaded_object = get_node(node_data["node_path"])

		loaded_object.load(node_data)
	
	savefile_loaded.emit()


func parse_map_file(_map: String) -> void:
	var lines = _map.split("\r\n")
	var first: bool = true
	
	var y: int = 1
	for l in lines:
		var data = l.split("\t")
		
		first = true
		
		if data.size() > 1:
			var x: int = 1
			for terrain_id in data:
				if first:
					first = false
					x = 0
					# print({"x": x, "y": y, "terrain": terrain_id})
					assert(int(terrain_id)==y)
				else:
					# print({"x": x, "y": y, "terrain": terrain_id})
					var location: Vector3i = Vector3i(x, y, 0)
					
					MapDetailsSingleton.update_location(location, int(terrain_id), -1)
					
				x += 1
			
			y += 1


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("quitting...")
		if MapDetailsSingleton.have_changes_to_save || MonsterDetailsSingleton.have_changes_to_save:
			print("changes pending")
			save_game()
		else:
			print("no unsaved changes")
		get_tree().quit() # default behavior
