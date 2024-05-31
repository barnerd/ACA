@tool
extends EditorScript

var map_data
var mob_data
var encounter_layer: EncounterLayer
var encounters_by_id: Dictionary = {}

# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	print("generating encounter labels")
	
	_load_save_file()
	#print(map_data["groups"])
	
	for e in mob_data["encounters"]:
		encounters_by_id[str(e["t_id"])+"|"+e["t"]] = e
	
	encounter_layer = get_scene()
	print(encounter_layer.name)
	print(encounter_layer.scene_file_path)
	print(encounter_layer.labels_by_coords)
	
	for tile in map_data["tiles"]:
		var loc: Vector3i = Vector3i(tile["x"], tile["y"], tile["z"])
			
		var tier: int = -1
		var tile_terrain = tile["t"]
		
		if tile["e"]:
			var encounter: EncounterTableDetails = null
			
			if encounters_by_id.has(tile.encounter_table_id):
				encounter = encounters_by_id[tile.encounter_table_id]
			
			if encounter:
				tier = encounter.tier_number
		
		# don't generate labels for water, snow L2, mountain L3, cap, arena
		if not [1,6,11,12,14].has(tile_terrain) and not encounter_layer.labels_by_coords.has(loc):
			encounter_layer._create_label(loc, tier, tile_terrain)
	
	
	print(encounter_layer.labels_by_coords)
	print("finished generating encounter labels")


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
		elif node_data["node_path"] == "/root/AgoniaData/MonsterDataBase":
			mob_data = node_data
