class_name MapDetails extends Node

@export var terrain_details: Array[TerrainType] = [
preload("res://Terrain Types/city.tres"),
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

var map_tiles : Dictionary = {} # Vector3i -> MapTiles

# TileMap Layers
var map_image_layer: int = 0

var have_changes_to_save: bool

# displays
# $"/root/Node2D/Control/PanelContainer/ScrollContainer/Control/HBoxContainer/PanelContainer/TerrainColors
@onready var terrain_colors_display: TerrainColors = $"/root/Node2D/Control/PanelContainer/ScrollContainer/Control/HBoxContainer/PanelContainer/TerrainColors"
@onready var tile_map_display: TileMap = $"/root/Node2D/Control/PanelContainer/ScrollContainer/Control/HBoxContainer/PanelContainer/MapImages"


func _init() -> void:
	have_changes_to_save = false
	
	for t in terrain_details:
		terrains_by_id[t.terrain_id] = t


func save():
	var tile_details: Array = []
	for tile in map_tiles.values():
		tile_details.append({
			"x": tile.location_x,
			"y": tile.location_y,
			"z": tile.location_z,
			"map": tile.tile_image_id,
			"t": tile.terrain_id,
			"e": tile.encounter_table_id
		})
	
	var save_dict = {
		"node_path": self.get_path(),
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"tiles" : tile_details
	}
	
	have_changes_to_save = false
	
	return save_dict


func load(_data):
	print("loading map details")
	map_tiles = {}
	
	for tile in _data["tiles"]:
		var l:Vector3i = Vector3i(tile["x"], tile["y"], tile["z"])
		update_location(l, tile["t"], tile["map"], tile["e"])


func update_location(_loc: Vector3i, _terrain_id: int, _map_id: int = -1, _encounter_id: int = -1):
	if map_tiles.has(_loc):
		map_tiles[_loc].terrain_id = _terrain_id
		map_tiles[_loc].terrain_details = terrains_by_id[_terrain_id]
		map_tiles[_loc].tile_image_id = _map_id
		map_tiles[_loc].encounter_table_id = _encounter_id
		have_changes_to_save = true
	else:
		map_tiles[_loc] = MapTile.new(_loc, _map_id, _terrain_id, _encounter_id)
	
	# Update Flat Color Display
	terrain_colors_display.paint_tile(Vector2i(_loc.x, _loc.y), terrains_by_id[_terrain_id].terrain_color_default)
	
	# Update TileMap Image Display
	if _map_id == -1:
		# turn off tile in TileMap
		tile_map_display.set_cell(map_image_layer, Vector2i(_loc.x, _loc.y), -1)
	else:
		tile_map_display.set_cell(map_image_layer, Vector2i(_loc.x, _loc.y), 0, Vector2i(_map_id % 76, floor(_map_id/76)))


class MapTile:

	var location_x: int
	var location_y: int
	var location_z: int
	var tile_image_id: int
	var terrain_id: int
	var terrain_details: TerrainType
	var encounter_table_id: int


	func _init(_location = Vector3i.ZERO, _tile_image_id = -1, _terrain_id = -1, _encounter_table_id = -1):
		location_x = _location.x
		location_y = _location.y
		location_z = _location.z
	
		tile_image_id = _tile_image_id
		terrain_id = _terrain_id
		encounter_table_id = _encounter_table_id
