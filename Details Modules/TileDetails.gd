class_name TileDetails extends VBoxContainer

@onready var section_header = $CenterContainer/RichTextLabel
@onready var terrain_type_label = $"HBoxContainer/Terrain Type"
@onready var movement_label = $HBoxContainer/Movement
@onready var map_id_label = $"Map id and Sprite/RichTextLabel"

var selected_tribe: String = "Dwarr"
var selected_terrain: TerrainType


func _ready() -> void:
	SignalBus.connect_signal("tilemap_location_clicked", on_tilemap_location_clicked)
	SignalBus.connect_signal("tribe_selected", on_tribe_select)


func on_tilemap_location_clicked(_coords: Vector3i, _button: MouseButton):
	if _button == MOUSE_BUTTON_LEFT:
		section_header.text = "Location Details ["+str(_coords.x)+","+str(_coords.y)+"]"
		
		var tile_details = MapDetailsSingleton.map_tiles[_coords]
		selected_terrain = tile_details.terrain_details
		
		_generate_terrain_type_label(selected_terrain.terrain_name, selected_terrain.terrain_color_custom)
		_generate_movement_label()
		
		map_id_label.text = "map-" + str(tile_details.tile_image_id)


func on_tribe_select(_tribe: String):
	selected_tribe = _tribe
	_generate_movement_label()


func _generate_terrain_type_label(_type: String, _color: Color) -> void:
	terrain_type_label.clear()
	terrain_type_label.push_color(_color)
	terrain_type_label.append_text(_type)
	terrain_type_label.pop()


func _generate_movement_label() -> void:
	movement_label.clear()
	match selected_tribe:
		"Dwarr":
			movement_label.append_text(str(selected_terrain.dwarr_mvp))
		"Leafborn":
			movement_label.append_text(str(selected_terrain.leafborn_mvp))
		"Lightfoot":
			movement_label.append_text(str(selected_terrain.lightfoot_mvp))
		"Mythos":
			movement_label.append_text(str(selected_terrain.mythos_mvp))
		"Norsk":
			movement_label.append_text(str(selected_terrain.norsk_mvp))
		"Giant":
			movement_label.append_text(str(selected_terrain.giant_mvp))
		"Kiith":
			movement_label.append_text(str(selected_terrain.kiith_mvp))
		"Nuruk":
			movement_label.append_text(str(selected_terrain.nuruk_mvp))
	movement_label.append_text(" movement")

