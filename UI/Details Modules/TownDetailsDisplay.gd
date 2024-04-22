class_name TownDetailsDisplay extends VBoxContainer

@onready var section_header = $CenterContainer/RichTextLabel
@onready var label_label = $RichTextLabel

var selected_terrain: TerrainType


func _ready() -> void:
	SignalBus.connect_to_signal("tilemap_location_clicked", on_tilemap_location_clicked)


func on_tilemap_location_clicked(_coords: Vector3i, _button: MouseButton):
	if _button == MOUSE_BUTTON_LEFT:
		var tile_details = AgoniaData.MapData.map_tiles[_coords]
		selected_terrain = tile_details.terrain_details
		
		if tile_details.town:
			label_label.text = str(_coords.x) + ", " + str(_coords.y)
			label_label.text += " - "
			if tile_details.town.town_name == "":
				label_label.text += "Hidden town"
			else:
				label_label.text += tile_details.town.town_name
		else:
			label_label.clear()

# Movement page:
# 	You are in Trading post, owned by Agonia Trading Company
# Group page:
# 	Town : Trading post at 266,192,0
# Lookaround:
# 	266, 192 - Trading post
# 	266, 192 - Hidden town
