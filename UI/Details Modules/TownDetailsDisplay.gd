class_name TownDetailsDisplay extends VBoxContainer

@onready var section_header = $"CenterContainer/Section Header"
@onready var town_name_label = $Town/Label
@onready var town_name_value = $Town/Value
@onready var group_name_label = $Group/Label
@onready var group_name_value = $Group/Value
@onready var watchtower_label = $Watchtower/Label
@onready var watchtower_value = $Watchtower/Value
@onready var dwelling_label = $Dwelling/Label
@onready var dwelling_value = $Dwelling/Value
@onready var building_label = $Buildings/Label
@onready var building_value = $Buildings/Value


func _ready() -> void:
	SignalBus.connect_to_signal("tilemap_location_clicked", on_tilemap_location_clicked)


func on_tilemap_location_clicked(_coords: Vector3i, _button: MouseButton):
	if _button == MOUSE_BUTTON_LEFT:
		var tile_details = AgoniaData.MapData.map_tiles[_coords]
	
		town_name_label.text = ""
		town_name_value.text = ""
		group_name_label.hide()
		group_name_value.text = ""
		watchtower_label.hide()
		watchtower_value.text = ""
		dwelling_label.hide()
		dwelling_value.text = ""
		building_label.hide()
		building_value.text = ""
		
		if tile_details.town:
			var town_details = tile_details.town
			town_name_label.text = "%d, %d - " % [_coords.x, _coords.y]
			if town_details.town_name == "":
				town_name_value.text += "Hidden town"
			else:
				town_name_value.text += town_details.town_name
			
			group_name_label.show()
			if town_details.group_id != -1:
				group_name_value.text = AgoniaData.MapData.groups_by_id[town_details.group_id].group_name
			else:
				group_name_value.text = "unknown"
			
			watchtower_label.show()
			if town_details.watchtower_view == -1:
				watchtower_value.text = "unknown"
			else:
				watchtower_value.text = str(town_details.watchtower_view)
			
			dwelling_label.show()
			match town_details.dwelling_size:
				TownDetails.Dwelling_Sizes.UNKNOWN:
					dwelling_value.text = "unknown"
				TownDetails.Dwelling_Sizes.NONE:
					dwelling_value.text = "0"
				TownDetails.Dwelling_Sizes.HUNDRED:
					dwelling_value.text = "100"
				TownDetails.Dwelling_Sizes.FIVE_HUNDRED:
					dwelling_value.text = "500"
			
			building_label.show()
			var buildings: Array[String] = []
			if town_details.buildings_bitmask != -1:
				if town_details.buildings_bitmask & TownDetails.Buildings.BLACKSMITH:
					buildings.append("Blacksmith")
				if town_details.buildings_bitmask & TownDetails.Buildings.WORKSHOP:
					buildings.append("Workshop")
				if town_details.buildings_bitmask & TownDetails.Buildings.ALCHEMICAL_LAB:
					buildings.append("Alchemical Lab")
				if town_details.buildings_bitmask & TownDetails.Buildings.WONDERS:
					buildings.append("Hall of Wonders")
				if buildings.size() == 0:
					building_value.text = ""
				else:
					building_value.text = ", ".join(buildings)
			else:
				building_value.text = "unknown"

# Movement page:
# 	You are in Trading post, owned by Agonia Trading Company
# Group page:
# 	Town : Trading post at 266,192,0
# Lookaround:
# 	266, 192 - Trading post
# 	266, 192 - Hidden town
