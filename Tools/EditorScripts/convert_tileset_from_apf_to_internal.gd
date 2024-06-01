@tool
extends EditorScript

var tile_map: TileMap


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	print("update tilemap from internal")
	
	tile_map = get_scene()
	
	print("Convert TileSet to Internal terrain_ids")
	var tile_set_source = tile_map.tile_set.get_source(0)
	for index in tile_set_source.get_tiles_count():
		var tileset_coords = tile_set_source.get_tile_id(index)
		var tile_data = tile_set_source.get_tile_data(tileset_coords, 0)

		var old_terrain_id = tile_data.get_custom_data("terrain_id")
		if not old_terrain_id == -1:
			var new_terrain_id = TerrainType.TERRAIN_ID_APF_TO_INTERNAL[old_terrain_id]
			tile_data.set_custom_data("terrain_id", new_terrain_id)
			
			#print({"old_id": old_terrain_id, "new_id": new_terrain_id, "tile_data": tile_data.get_custom_data("terrain_id")})
	
	print("done updating tileset")
