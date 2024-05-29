extends TileMap

enum TileMap_Layers {MAP_IMAGE = 0, MINES = 1, TOWNS = 2}
enum TileMap_Sources {NONE = -1, SPRITE_SHEET = 0, TOWN = 2, COPPER = 3, IRON = 4, TIN = 5, TITANIUM = 6}
var mine_type_to_tilemap_source: Array[int] = [TileMap_Sources.TIN, TileMap_Sources.COPPER, TileMap_Sources.IRON, TileMap_Sources.TITANIUM]
var mine_string_to_mine_type: Array[String] = ["tin", "copper", "iron", "titanium"]


func _ready() -> void:
	SignalBus.connect_to_signal("town_view_settings_changed", on_town_view_settings_changed)
	SignalBus.connect_to_signal("tile_updated", on_tile_updated)


func on_town_view_settings_changed(_settings) -> void:
	print(_settings)
	
	for town in AgoniaData.MapData.towns_by_location.values():
		var display: bool = true
		
		# { "watchtower": 0, "dwelling": 0, "blacksmith": true, "workshop": false, "lab": false, "hall": false }
		if _settings["watchtower"] != 0 && town.watchtower_view < _settings["watchtower"]:
			display = false
		
		if _settings["dwelling"] != 0 && int(town.dwelling_size) < _settings["dwelling"]:
			display = false
		
		if town.buildings_bitmask == -1 && _settings["blacksmith"]:
			display = false
		if _settings["blacksmith"] && not (town.buildings_bitmask & TownDetails.Buildings.BLACKSMITH):
			display = false
		
		if town.buildings_bitmask == -1 && _settings["workshop"]:
			display = false
		if _settings["workshop"] && not (town.buildings_bitmask & TownDetails.Buildings.WORKSHOP):
			display = false
		
		if town.buildings_bitmask == -1 && _settings["lab"]:
			display = false
		if _settings["lab"] && not (town.buildings_bitmask & TownDetails.Buildings.ALCHEMICAL_LAB):
			display = false
		
		if town.buildings_bitmask == -1 && _settings["hall"]:
			display = false
		if _settings["hall"] && not (town.buildings_bitmask & TownDetails.Buildings.WONDERS):
			display = false
		
		if display:
			set_cell(AgoniaData.MapData.TileMap_Layers.TOWNS, Vector2i(town.location.x, town.location.y), AgoniaData.MapData.TileMap_Sources.TOWN, Vector2i.ZERO)
		else:
			set_cell(AgoniaData.MapData.TileMap_Layers.TOWNS, Vector2i(town.location.x, town.location.y), AgoniaData.MapData.TileMap_Sources.NONE)


func on_tile_updated(_location: Vector3i) -> void:
	var tile = AgoniaData.MapData.map_tiles[_location]
	var loc: Vector2i = Vector2i(tile["x"], tile["y"])
	
	var _map_id: int = int(tile["map"])
	self.set_cell(TileMap_Layers.MAP_IMAGE, loc, TileMap_Sources.SPRITE_SHEET, Vector2i(_map_id % 76, floori(_map_id/76.0)))
	
	for mine in tile.mines:
		var type: int = mine.type
		self.set_cell(TileMap_Layers.MINES, loc, mine_type_to_tilemap_source[type], Vector2i.ZERO)
	
	if AgoniaData.MapData.towns_by_location.has(_location):
		self.set_cell(TileMap_Layers.TOWNS, loc, TileMap_Sources.TOWN, Vector2i.ZERO)
	else:
		self.set_cell(TileMap_Layers.TOWNS, loc, TileMap_Sources.NONE)
