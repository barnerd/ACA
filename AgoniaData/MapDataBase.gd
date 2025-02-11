class_name MapDataBase extends Node

const MAP_SIZE: Vector3i = Vector3i(400, 400, 1)
const TILE_SIZE: Vector2i = Vector2i(24, 24)

@export var terrain_details: Array[TerrainType] = [
preload("res://Terrain Types/city.tres"),
preload("res://Terrain Types/floor.tres"),
preload("res://Terrain Types/desert.tres"),
preload("res://Terrain Types/forest.tres"),
preload("res://Terrain Types/ice1.tres"),
preload("res://Terrain Types/ice2.tres"),
preload("res://Terrain Types/lava.tres"),
preload("res://Terrain Types/mountain1.tres"),
preload("res://Terrain Types/mountain2.tres"),
preload("res://Terrain Types/mountain3.tres"),
preload("res://Terrain Types/plains.tres"),
preload("res://Terrain Types/road.tres"),
preload("res://Terrain Types/snow.tres"),
preload("res://Terrain Types/wastes.tres"),
preload("res://Terrain Types/water.tres")]
var terrains_by_id: Dictionary = {} # terrain_id -> TerrainType

var map_tiles: Dictionary = {} # Vector3i -> MapTiles

var mines_locations_permanent: Dictionary = {} # Mine_type -> Vector3i -> MineLocation
var mines_locations_temporary: Dictionary = {} # Mine_type -> Vector3i -> MineLocation

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
		save_tile_details.append({
			"x": tile.location.x,
			"y": tile.location.y,
			"z": tile.location.z,
			"map": tile.tile_image_id,
			"t": tile.terrain_id,
			"e": tile.encounter_table_id
		})
	
	# save mines data
	var save_mines_permanent: Array = []
	for type in mines_locations_permanent:
		for mine_loc in mines_locations_permanent[type]:
			save_mines_permanent.append({
				"x": mine_loc.x,
				"y": mine_loc.y,
				"z": mine_loc.z,
				"t": type
			})
	
	var save_mines_temporary: Array = []
	for type in mines_locations_temporary:
		for mine_loc in mines_locations_temporary[type]:
			save_mines_temporary.append({
				"x": mine_loc.x,
				"y": mine_loc.y,
				"z": mine_loc.z,
				"t": type
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
		"mines_p" : save_mines_permanent, 
		"mines_t": save_mines_temporary,
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
		update_location(l, tile["t"], tile["map"], tile["e"])
	
	# load mine data
	mines_locations_permanent = {} # Mine_type -> [Vector3i]
	for mine in _data["mines_p"]:
		var l: Vector3i = Vector3i(mine["x"], mine["y"], mine["z"])
		add_mine_location(mine["t"], l,  true)
	
	mines_locations_temporary = {} # Mine_type -> [Vector3i]
	for mine in _data["mines_t"]:
		var l: Vector3i = Vector3i(mine["x"], mine["y"], mine["z"])
		add_mine_location(mine["t"], l)
	
	groups_by_id = {} # group_id: int -> GroupDetails
	for group in _data["groups"]:
		update_group(group["g_id"], group["n"], group["f"])
	
	towns_by_location = {} # Vector3i -> TownDetails
	for town in _data["towns"]:
		var l: Vector3i = Vector3i(town["x"], town["y"], town["z"])
		update_town(town["t_id"], town["n"], town["g_id"], l, town["w"], town["d"], town["b"])


func update_location(_loc: Vector3i, _terrain_id: int, _map_id: int = -1, _encounter_id: String = ""):
	if map_tiles.has(_loc):
		if not map_tiles[_loc].terrain_id == _terrain_id:
			map_tiles[_loc].terrain_id = _terrain_id
			map_tiles[_loc].encounter_table_id = ""
		if not _terrain_id == -1:
			map_tiles[_loc].terrain_details = terrains_by_id[_terrain_id]
		map_tiles[_loc].tile_image_id = _map_id
		map_tiles[_loc].encounter_table_id = _encounter_id
		
		# Update Encounter Labels
		#var vector_array: Array[Vector3i] = [_loc]
		#TODO: should this be a signal?
		#encounters_updated.emit(vector_array)
		#AgoniaData.MonsterData.encounter_layer.update_labels(vector_array)
	else:
		map_tiles[_loc] = TileDetails.new(_loc, _map_id, _terrain_id, _encounter_id)


func add_mine_location(_type: MineDetails.Mine_Types, _loc: Vector3i, _perm: bool = false):
	var new_mine = MineDetails.new(_type, _loc, _perm)
	
	if _perm:
		if not mines_locations_permanent.has(_type):
			mines_locations_permanent[_type] = {}
		
		if not mines_locations_permanent[_type].has(_loc):
			mines_locations_permanent[_type][_loc] = new_mine
			map_tiles[_loc].mines.append(new_mine)
	else:
		if not mines_locations_temporary.has(_type):
			mines_locations_temporary[_type] = {}
		
		if not mines_locations_temporary[_type].has(_loc):
			mines_locations_temporary[_type][_loc] = new_mine
			map_tiles[_loc].mines.append(new_mine)


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
