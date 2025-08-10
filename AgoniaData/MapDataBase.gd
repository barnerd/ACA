class_name MapDataBase extends Node

const MAP_SIZE: Vector3i = Vector3i(400, 400, 1)
const TILE_SIZE: Vector2i = Vector2i(24, 24)

@export var terrain_details: Array[TerrainType] = [
preload("res://resources/terrain_types/city.tres"),
preload("res://resources/terrain_types/floor.tres"),
preload("res://resources/terrain_types/desert.tres"),
preload("res://resources/terrain_types/forest.tres"),
preload("res://resources/terrain_types/ice1.tres"),
preload("res://resources/terrain_types/ice2.tres"),
preload("res://resources/terrain_types/lava.tres"),
preload("res://resources/terrain_types/mountain1.tres"),
preload("res://resources/terrain_types/mountain2.tres"),
preload("res://resources/terrain_types/mountain3.tres"),
preload("res://resources/terrain_types/plains.tres"),
preload("res://resources/terrain_types/road.tres"),
preload("res://resources/terrain_types/snow.tres"),
preload("res://resources/terrain_types/wastes.tres"),
preload("res://resources/terrain_types/water.tres")]
var terrains_by_id: Dictionary = {} # terrain_id -> TerrainType

var map_tiles: Dictionary = {} # Vector3i -> MapTiles

var groups_by_id: Dictionary = {} # group_id: int -> GroupDetails
var towns_by_location: Dictionary = {} # Vector3i -> TownDetails

var have_changes_to_save: bool

# displays
@onready var tile_map_display: TileMap = $/root/MapViewer/PanelContainer/VBoxContainer/HBoxContainer/ScrollContainer/Control/PanelContainer/MapImages


func _init() -> void:
	have_changes_to_save = false
	
	for t in terrain_details:
		terrains_by_id[t.terrain_id] = t


func _input(event) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F:
			if event.meta_pressed:
				print("Cmd-F was pressed")
				


func save():
	# save tile data
	var save_tile_details: Array = []
	for tile in map_tiles.values():
		#var enc = AgoniaData.MonsterData.get_encounter_table_by_id(tile.encounter_table_id)
		#var e_id = enc.internal_id if enc else -1
		save_tile_details.append({
			"x": tile.location.x,
			"y": tile.location.y,
			"z": tile.location.z,
			"map": tile.tile_image_id,
			"t": tile.terrain_id,
			"e": tile.encounter_table_id,
		})
	
	# save group details
	var save_group_details: Array = []
	for id in groups_by_id:
		save_group_details.append({
			"g_id": id,
			"n": groups_by_id[id].group_name,
			"f": groups_by_id[id].group_faction
		})
	
	var save_town_details: Array = []
	for town_loc in towns_by_location:
		save_town_details.append({
			"g_id": towns_by_location[town_loc].group_id,
			"t_id": towns_by_location[town_loc].town_id,
			"n": towns_by_location[town_loc].town_name,
			"x": towns_by_location[town_loc].location.x,
			"y": towns_by_location[town_loc].location.y,
			"z": towns_by_location[town_loc].location.z,
			"w": towns_by_location[town_loc].watchtower_view,
			"d": towns_by_location[town_loc].dwelling_size,
			"b": towns_by_location[town_loc].buildings_bitmask
		})
	
	var save_dict = {
		"node_path": self.get_path(),
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"tiles" : save_tile_details,
		"groups" : save_group_details,
		"towns" : save_town_details
	}
	
	have_changes_to_save = false
	
	return save_dict


func load(_data):
	print("loading map details")
	map_tiles = {} # Vector3i -> MapTiles
	
	# load map tile data
	for tile in _data["tiles"]:
		var l: Vector3i = Vector3i(tile["x"], tile["y"], tile["z"])
		# convert tile["e"]
		var e_id: int = tile["e"] # -1
		#for enc in AgoniaData.MonsterData.encounters_by_id.values():
			#if enc.encounter_id == tile["e"]:
				#e_id = enc.id
				#break
		update_location(l, tile["t"], tile["map"], e_id)
	
	groups_by_id = {} # group_id: int -> GroupDetails
	for group in _data["groups"]:
		update_group(group["g_id"], group["n"], group["f"])
	
	towns_by_location = {} # Vector3i -> TownDetails
	for town in _data["towns"]:
		var l: Vector3i = Vector3i(town["x"], town["y"], town["z"])
		update_town(town["t_id"], town["n"], town["g_id"], l, town["w"], town["d"], town["b"])


func update_location(_loc: Vector3i, _terrain_id: int, _map_id: int = -1, _encounter_id: int = -1):
	if map_tiles.has(_loc):
		if not map_tiles[_loc].terrain_id == _terrain_id:
			map_tiles[_loc].terrain_id = _terrain_id
			map_tiles[_loc].encounter_table_id = ""
		map_tiles[_loc].tile_image_id = _map_id
		map_tiles[_loc].encounter_table_id = _encounter_id
		
		# Update Encounter Labels
		#var vector_array: Array[Vector3i] = [_loc]
		#TODO: should this be a signal?
		#encounters_updated.emit(vector_array)
		#AgoniaData.MonsterData.encounter_layer.update_labels(vector_array)
	else:
		map_tiles[_loc] = TileDetails.new(_loc, _map_id, _terrain_id, _encounter_id)


func update_group(_id: int, _name: String, _faction: GroupDetails.Factions):
	if groups_by_id.has(_id):
		groups_by_id[_id].group_name = _name
		groups_by_id[_id].group_faction = _faction
	else:
		groups_by_id[_id] = GroupDetails.new(_id, _name, _faction)


func update_town(_town_id: int, _name: String, _group_id: int, _loc: Vector3i, _watchtower: int = -1, _dwelling: TownDetails.Dwelling_Sizes = TownDetails.Dwelling_Sizes.UNKNOWN, _buildings: int = -1):
	if towns_by_location.has(_loc):
		towns_by_location[_loc].town_id = _town_id
		towns_by_location[_loc].town_name = _name
		towns_by_location[_loc].group_id = _group_id
		towns_by_location[_loc].watchtower_view = _watchtower
		towns_by_location[_loc].dwelling_size = _dwelling
		towns_by_location[_loc].buildings_bitmask = _buildings
	else:
		var new_town = TownDetails.new(_town_id, _name, _group_id, _loc, _watchtower, _dwelling, _buildings)
	
		towns_by_location[_loc] = new_town
		map_tiles[_loc].town = new_town
		
		if _group_id != -1:
			groups_by_id[_group_id].towns.append(new_town)
