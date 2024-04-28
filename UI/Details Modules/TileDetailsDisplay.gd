class_name TileDetailsDisplay extends VBoxContainer

@onready var section_header = $"CenterContainer/Section Header"
@onready var terrain_type_value = $"Terrain Type/Value"
@onready var movement_value = $Mvp/Value
@onready var movement_label = $Mvp/Label
@onready var map_id_label = $"Map id and Sprite/Label"
@onready var mine_label = $Mines/Label

var selected_tribe: String = "Dwarr"
var selected_terrain: TerrainType


func _ready() -> void:
	SignalBus.connect_to_signal("tilemap_location_clicked", on_tilemap_location_clicked)
	SignalBus.connect_to_signal("tribe_selected", on_tribe_select)


func on_tilemap_location_clicked(_coords: Vector3i, _button: MouseButton):
	if _button == MOUSE_BUTTON_LEFT:
		section_header.text = "Location Details ["+str(_coords.x)+","+str(_coords.y)+"]"
		
		var tile_details = AgoniaData.MapData.map_tiles[_coords]
		selected_terrain = tile_details.terrain_details
		
		if selected_terrain:
			terrain_type_value.text = selected_terrain.terrain_name
			_generate_movement_label()
			
			map_id_label.text = "map-" + str(tile_details.tile_image_id)
			
			var mine_names: Array[String] = []
			
			for m in tile_details.mines:
				mine_names.append(m.type_name)
			mine_label.text = ", ".join(mine_names)
		else:
			terrain_type_value.text = ""
			movement_value.text = ""
			movement_label.text = ""
			map_id_label.text = "map-" + str(tile_details.tile_image_id)


func on_tribe_select(_tribe: String):
	selected_tribe = _tribe
	_generate_movement_label()


#func _generate_terrain_type_label(_type: String, _color: Color) -> void:
	#terrain_type_label.clear()
	#terrain_type_label.append_text("Type of land: ")
	#terrain_type_label.push_color(_color)
	#terrain_type_label.append_text(_type)
	#terrain_type_label.pop()


func _generate_movement_label() -> void:
	var mvp: int = -1
	if selected_terrain:
		match selected_tribe:
			"Dwarr":
				mvp = selected_terrain.dwarr_mvp
			"Leafborn":
				mvp = selected_terrain.leafborn_mvp
			"Lightfoot":
				mvp = selected_terrain.lightfoot_mvp
			"Mythos":
				mvp = selected_terrain.mythos_mvp
			"Norsk":
				mvp = selected_terrain.norsk_mvp
			"Giant":
				mvp = selected_terrain.giant_mvp
			"Kiith":
				mvp = selected_terrain.kiith_mvp
			"Nuruk":
				mvp = selected_terrain.nuruk_mvp
	
	if mvp == -1:
		movement_value.text = ""
		movement_label.text = "you cannot move this way"
	else:
		movement_value.text = str(mvp)
		movement_label.text = "movement"

