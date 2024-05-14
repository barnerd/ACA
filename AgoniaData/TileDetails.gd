class_name TileDetails extends Node

var location: Vector3i

var tile_image_id: int
var terrain_id: int
var terrain_details: TerrainType
var encounter_table_id: String

var mines: Array[MineDetails] = []
var town: TownDetails


func _init(_loc: Vector3i = Vector3i.ZERO, _tile_image_id: int = -1, _terrain_id: int = -1, _encounter_table_id: String = ""):
	location = _loc
	
	tile_image_id = _tile_image_id
	terrain_id = _terrain_id
	if not terrain_id == -1:
		terrain_details = AgoniaData.MapData.terrains_by_id[_terrain_id]
	encounter_table_id = _encounter_table_id
