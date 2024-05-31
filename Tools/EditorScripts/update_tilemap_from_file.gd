@tool
extends EditorScript

var map_data
var tile_map: TileMap


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	print("update tilemap from file")
	
	_load_save_file()
	#print(map_data["groups"])
	
	tile_map = get_scene()
	
	for tile in map_data["tiles"]:
		var loc: Vector2i = Vector2i(tile["x"], tile["y"])
		var _map_id: int = int(tile["map"])
		tile_map.set_cell(tile_map.TileMap_Layers.MAP_IMAGE, loc, tile_map.TileMap_Sources.SPRITE_SHEET, Vector2i(_map_id % 76, floori(_map_id/76.0)))
	
	for mine in map_data["mines_p"]:
		var loc: Vector2i = Vector2i(mine["x"], mine["y"])
		var type: int = int(mine["t"])
		tile_map.set_cell(tile_map.TileMap_Layers.MINES, loc, MapImages.mine_type_to_tilemap_source[type], Vector2i.ZERO)
	
	for mine in map_data["mines_t"]:
		var loc: Vector2i = Vector2i(mine["x"], mine["y"])
		var type: int = int(mine["t"])
		tile_map.set_cell(tile_map.TileMap_Layers.MINES, loc, MapImages.mine_type_to_tilemap_source[type], Vector2i.ZERO)
	
	for town in map_data["towns"]:
		var loc: Vector2i = Vector2i(town["x"], town["y"])
		tile_map.set_cell(tile_map.TileMap_Layers.TOWNS, loc, tile_map.TileMap_Sources.TOWN, Vector2i.ZERO)
	
	print("done updating tilemap")


func _load_save_file() -> void:
	print("loading file...")
	if not FileAccess.file_exists("res://savegame.txt"):
		return # Error! We don't have a save to load.

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
		
		if node_data["node_path"] == "/root/AgoniaData/MapDataBase":
			map_data = node_data
