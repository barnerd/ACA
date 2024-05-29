extends Node

var apf_flat_filename: String = "res://Flat Files/agoniaMap2.txt"

signal save_game_requested
signal savefile_loaded


func _init() -> void:
	SignalBus.register_signal("savefile_loaded", savefile_loaded)
	SignalBus.register_signal("save_game_requested", save_game_requested)


func _ready() -> void:
	#var agoniaMap:String = load_file(apf_flat_filename)
	#parse_map_file(agoniaMap)
	load_game()
	
	# temporary data commands go here
	#print("running temp commands")
	#var t_id_a: Array[int] = [7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 13, 13, 13, 13, 13, 13, 13, 13, 13, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0]
	#var tier_a: Array[String] = ["T1", "T2", "T3a", "T3b", "T4", "T5", "T6", "T7", "T8", "T9", "T1", "T2", "T3", "T4", "T5", "T6", "T7", "T8", "T9", "T1", "T2", "T3", "T4", "T5", "T6a", "T7", "T8", "T9", "T1", "T2", "T3", "T4", "T5", "T6", "T8", "T1", "T2", "T3", "T4", "T5", "T6", "T7", "T9"]
	#var internal_id_a: Array[int] = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 15, 16, 17, 18, 19, 20, 21, 22, 23, 28, 29, 30, 31, 32, 33, 34, 35, 36, 40, 41, 42, 43, 44, 45, 46, 52, 53, 54, 55, 56, 57, 58, 59]
	#var internal_id_confirmed_a: Array[bool] = [true, false, true, false, false, false, false, false, false, true, false, true, false, false, false, false, true, false, false, false, false, true, false, false, false, true, false, false, true, true, false, false, false, false, false, true, false, false, false, false, true, false, false]
	#
	#for i in tier_a.size():
		#var t_id: int = t_id_a[i]
		#var tier: String = tier_a[i]
		#var e = AgoniaData.MonsterData.encounters_by_terrain_tier[t_id][tier]
		#e.internal_id = internal_id_a[i]
		#e.internal_id_confirmed = internal_id_confirmed_a[i]
	#print("done running temp commands")
	
	#$"../Control/PanelContainer/ScrollContainer/Control/HBoxContainer/PanelContainer/TerrainColors".apply_image()
	#tile_map_display.visible = false


func _input(event) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_S:
			if event.meta_pressed:
				print("Cmd-S was pressed")
				save_game_requested.emit()
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
	var tile_set_source = AgoniaData.MapData.tile_map_display.tile_set.get_source(0)
	for index in tile_set_source.get_tiles_count():
		var tileset_coords = tile_set_source.get_tile_id(index)
		var tile_data = tile_set_source.get_tile_data(tileset_coords, 0)

		var old_terrain_id = tile_data.get_custom_data("terrain_id")
		if not old_terrain_id == -1:
			var new_terrain_id = TerrainType.TERRAIN_ID_APF_TO_INTERNAL[old_terrain_id]
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
					
					AgoniaData.MapData.update_location(location, int(terrain_id), -1)
					
				x += 1
			
			y += 1


#func _notification(what):
	#if what == NOTIFICATION_WM_CLOSE_REQUEST:
		#print("quitting...")
		#if AgoniaData.MapData.have_changes_to_save || AgoniaData.MonsterData.have_changes_to_save:
			#print("changes pending")
			#save_game()
		#else:
			#print("no unsaved changes")
		#get_tree().quit() # default behavior
