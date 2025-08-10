class_name TileDetails

var location: Vector3i

var tile_image_id: int # get from TileMap
var terrain_id: int # get from TileMap
var encounter_table_id: int

var town: TownDetails # move to Resource List


func _init(_loc: Vector3i = Vector3i.ZERO, _tile_image_id: int = -1, _terrain_id: int = -1, _encounter_table_id: int = -1):
	location = _loc
	
	tile_image_id = _tile_image_id
	terrain_id = _terrain_id
	encounter_table_id = _encounter_table_id
