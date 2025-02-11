class_name MapImages extends TileMap

enum TileMap_Layers {MAP_IMAGE = 0, MINES = 1, TOWNS = 2, BOATS = 3, ENCOUNTERS = 4}
enum TileMap_Sources {NONE = -1, SPRITE_SHEET = 0, TOWN = 2, COPPER = 3, IRON = 4, TIN = 5, TITANIUM = 6, NUMBERS = 7}
enum Numbers_Map {LIGHT = 0, DARK = 1}
const mine_type_to_tilemap_source: Array[int] = [TileMap_Sources.TIN, TileMap_Sources.COPPER, TileMap_Sources.IRON, TileMap_Sources.TITANIUM]
const mine_string_to_mine_type: Array[String] = ["tin", "copper", "iron", "titanium"]

var min_encounter_tier_to_display: int = 5


func _ready() -> void:
	SignalBus.connect_to_signal("town_view_settings_changed", on_town_view_settings_changed)
	SignalBus.connect_to_signal("tile_updated", on_tile_updated)
	
	SignalBus.connect_to_signal("savefile_loaded", update_encounter_layer)

	SignalBus.connect_to_signal("min_encounter_tier_selected", on_min_tier_selected)
	SignalBus.connect_to_signal("show_encounter_layer_toggled", show_encounter_layer)


func on_min_tier_selected(_tier: int) -> void:
	min_encounter_tier_to_display = _tier
	
	update_encounter_layer()


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
			set_cell(TileMap_Layers.TOWNS, Vector2i(town.location.x, town.location.y), TileMap_Sources.TOWN, Vector2i.ZERO)
		else:
			set_cell(TileMap_Layers.TOWNS, Vector2i(town.location.x, town.location.y), TileMap_Sources.NONE)


func on_tile_updated(_location: Vector3i) -> void:
	var tile = AgoniaData.MapData.map_tiles[_location]
	var loc: Vector2i = Vector2i(tile.location.x, tile.location.y)
	
	var _map_id: int = int(tile.tile_image_id)
	self.set_cell(TileMap_Layers.MAP_IMAGE, loc, TileMap_Sources.SPRITE_SHEET, Vector2i(_map_id % 76, floori(_map_id/76.0)))
	
	for mine in tile.mines:
		var type: int = mine.type
		self.set_cell(TileMap_Layers.MINES, loc, mine_type_to_tilemap_source[type], Vector2i.ZERO)
	
	if AgoniaData.MapData.towns_by_location.has(_location):
		self.set_cell(TileMap_Layers.TOWNS, loc, TileMap_Sources.TOWN, Vector2i.ZERO)
	else:
		self.set_cell(TileMap_Layers.TOWNS, loc, TileMap_Sources.NONE)


func show_encounter_layer(toggled_on: bool) -> void:
	set_layer_enabled(TileMap_Layers.ENCOUNTERS, toggled_on)


func update_encounter_layer() -> void:
	for y in range(0, AgoniaData.MapData.MAP_SIZE.y):
		for x in range(0, AgoniaData.MapData.MAP_SIZE.x):
			var loc = Vector2i(x, y)
			var tile = AgoniaData.MapData.map_tiles[Vector3i(loc.x, loc.y, 0)]
			
			var tier: int = -1
			var tile_terrain = tile.terrain_id
			
			if tile.encounter_table_id:
				var encounter = AgoniaData.MonsterData.get_encounter_table_by_id(tile.encounter_table_id)
				
				tier = encounter.tier_number
			
			# don't generate labels for water, snow L2, mountain L3, cap, arena
			if tier > 1 and tier >= min_encounter_tier_to_display and not [1,6,11,12,14].has(tile_terrain):
				var variation: int = Numbers_Map.LIGHT
				# use black text if on desert, snow, icy 1, else white
				if [0,9,10].has(tile_terrain):
					variation = Numbers_Map.DARK
				
				self.set_cell(TileMap_Layers.ENCOUNTERS, loc, TileMap_Sources.NUMBERS, Vector2i(variation, tier - 1))
			else:
				self.set_cell(TileMap_Layers.ENCOUNTERS, loc, TileMap_Sources.NONE)
