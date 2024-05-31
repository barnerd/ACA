extends Window

@onready var coords_label = $PanelContainer/MarginContainer/VBoxContainer/LocationLabel
@onready var map_image_value = $PanelContainer/MarginContainer/VBoxContainer/MapImageHBox/LineEdit
@onready var terrain_options = $PanelContainer/MarginContainer/VBoxContainer/TerrainOptions
@onready var mines_value = $PanelContainer/MarginContainer/VBoxContainer/MinesVBox/Label
@onready var mines_options = $PanelContainer/MarginContainer/VBoxContainer/MinesVBox/AddMineHBox/OptionButton
@onready var town_value = $PanelContainer/MarginContainer/VBoxContainer/TownVBox/Label

var tile_details
var tile_updated_signal
var updated_completed_signal


func _ready() -> void:
	SignalBus.connect_to_signal("tilemap_location_clicked", on_tilemap_location_clicked)
	SignalBus.connect_to_signal("savefile_loaded", on_savefile_loaded)
	
	tile_updated_signal = SignalBus.get_signal("tile_updated")
	updated_completed_signal = SignalBus.get_signal("update_completed")


func on_savefile_loaded() -> void:
	generate_terrain_options()
	generate_mine_options()


func generate_terrain_options() -> void:
	for t in AgoniaData.MapData.terrain_details:
		terrain_options.add_item(t.terrain_name, t.terrain_id)


func generate_mine_options() -> void:
	for m in MineDetails.Mine_Types.values():
		mines_options.add_item(MineDetails.mine_names[m], m)


func on_tilemap_location_clicked(_coords: Vector3i, _button: MouseButton):
	if _button == MOUSE_BUTTON_LEFT:
		tile_details = null
		if AgoniaData.MapData.map_tiles.has(_coords):
			tile_details = AgoniaData.MapData.map_tiles[_coords]
		print(tile_details)
		coords_label.text = "Location Details [%d,%d]" % [_coords.x, _coords.y]
		
		if tile_details:
			map_image_value.text = str(tile_details.tile_image_id)
			
			terrain_options.select(terrain_options.get_item_index(tile_details.terrain_id))
			
			_update_mines_display()
			
			_update_town_display()


func _update_mines_display() -> void:
	var mine_names: Array[String] = []
	mines_value.visible = (tile_details.mines.size() > 0)
	for m in tile_details.mines:
		mine_names.append(m.type_name)
	mines_value.text = ", ".join(mine_names)


func _update_town_display() -> void:
	if tile_details.town:
		town_value.visible = true
		if tile_details.town.town_name == "":
			town_value.text = "Unknown"
		else:
			town_value.text = tile_details.town.town_name
	else:
		town_value.visible = false
		town_value.text = ""


func _on_add_mine_button_pressed() -> void:
	var mine_id = mines_options.get_selected_id()
	AgoniaData.MapData.add_mine_location(mine_id, tile_details.location)
	
	tile_details.mines = AgoniaData.MapData.map_tiles[tile_details.location].mines
	_update_mines_display()
	if not tile_updated_signal.is_null():
		tile_updated_signal.emit(tile_details.location)


func _on_add_town_button_pressed() -> void:
	# add town at tile_details.location
	if not AgoniaData.MapData.towns_by_location.has(tile_details.location):
		AgoniaData.MapData.update_town(-1, "", -1, tile_details.location)
	
	tile_details.town = AgoniaData.MapData.map_tiles[tile_details.location].town
	_update_town_display()
	if not tile_updated_signal.is_null():
		tile_updated_signal.emit(tile_details.location)


func _on_update_button_pressed() -> void:
	if tile_details:
		AgoniaData.MapData.map_tiles[tile_details.location].tile_image_id = int(map_image_value.text)
		
		var new_terrain_id = terrain_options.get_selected_id()
		if new_terrain_id == 99:
			AgoniaData.MapData.map_tiles[tile_details.location].terrain_id = -1
			AgoniaData.MapData.map_tiles[tile_details.location].terrain_details = null
		else:
			AgoniaData.MapData.map_tiles[tile_details.location].terrain_id = new_terrain_id
			AgoniaData.MapData.map_tiles[tile_details.location].terrain_details = AgoniaData.MapData.terrains_by_id[new_terrain_id]
		
		if not tile_updated_signal.is_null():
			tile_updated_signal.emit(tile_details.location)
			
		if not updated_completed_signal.is_null():
			updated_completed_signal.emit()
