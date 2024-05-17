extends TileMap


func _ready() -> void:
	SignalBus.connect_to_signal("town_view_settings_changed", on_town_view_settings_changed)


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
