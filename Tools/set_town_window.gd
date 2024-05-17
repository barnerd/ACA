extends Window

@onready var coords_label = $"PanelContainer/MarginContainer/VBoxContainer/Name & Location HBoxContainer/Coords Label"
@onready var town_name = $"PanelContainer/MarginContainer/VBoxContainer/Name & Location HBoxContainer/TextEdit"
@onready var town_id = $"PanelContainer/MarginContainer/VBoxContainer/Name & Location HBoxContainer/HBoxContainer/TextEdit"
@onready var group_name = $"PanelContainer/MarginContainer/VBoxContainer/Group HBoxContainer/OptionButton"
@onready var watchtower_view = $"PanelContainer/MarginContainer/VBoxContainer/Watchtower HBoxContainer/OptionButton"
@onready var dwelling_size = $"PanelContainer/MarginContainer/VBoxContainer/Dwelling HBoxContainer/OptionButton"
@onready var blacksmith_toggle = $"PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/Blacksmith CheckBox"
@onready var workshop_toggle = $"PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/Workshop CheckBox"
@onready var lab_toggle = $"PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/Lab CheckBox"
@onready var hall_toggle = $"PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/Hall CheckBox"

var town_details


func _ready() -> void:
	SignalBus.connect_to_signal("tilemap_location_clicked", on_tilemap_location_clicked)


func _on_visibility_changed() -> void:
	# this is clearing the selection as well
	group_name.clear()
	
	for group in AgoniaData.MapData.groups_by_id.values():
		group_name.add_item(group.group_name, group.group_id)


func on_tilemap_location_clicked(_coords: Vector3i, _button: MouseButton):
	if _button == MOUSE_BUTTON_LEFT:
		town_details = null
		if AgoniaData.MapData.towns_by_location.has(_coords):
			town_details = AgoniaData.MapData.towns_by_location[_coords]
		
		coords_label.text = "%d, %d - " % [_coords.x, _coords.y]
		
		if town_details:
			town_name.text = town_details.town_name
			town_id.text = str(town_details.town_id)
			
			print(town_details.group_id)
			group_name.select(group_name.get_item_index(town_details.group_id))
			
			watchtower_view.select(town_details.watchtower_view + 1) # +1 because unknown is -1
			dwelling_size.select(town_details.dwelling_size)
			
			print(town_details.buildings_bitmask)
			if town_details.buildings_bitmask != -1:
				if town_details.buildings_bitmask & TownDetails.Buildings.BLACKSMITH:
					blacksmith_toggle.button_pressed = true
				if town_details.buildings_bitmask & TownDetails.Buildings.WORKSHOP:
					workshop_toggle.button_pressed = true
				if town_details.buildings_bitmask & TownDetails.Buildings.ALCHEMICAL_LAB:
					lab_toggle.button_pressed = true
				if town_details.buildings_bitmask & TownDetails.Buildings.WONDERS:
					hall_toggle.button_pressed = true
			else:
				blacksmith_toggle.button_pressed = false
				workshop_toggle.button_pressed = false
				lab_toggle.button_pressed = false
				hall_toggle.button_pressed = false
		else:
			town_name.text = "Name"
			town_id.text = "Id"
			
			group_name.text = "Group"
			
			watchtower_view.select(0)
			dwelling_size.select(0)
			
			blacksmith_toggle.button_pressed = false
			workshop_toggle.button_pressed = false
			lab_toggle.button_pressed = false
			hall_toggle.button_pressed = false


func _on_update_button_pressed() -> void:
	if town_details:
		town_details.town_name = town_name.text
		town_details.town_id = int(town_id.text)
		
		town_details.group_id = group_name.get_item_id(group_name.selected)
		
		town_details.watchtower_view = watchtower_view.selected - 1 # +1 because unknown is -1
		town_details.dwelling_size = dwelling_size.selected
		
		var bitmask: int = 0
		
		if blacksmith_toggle.button_pressed:
			bitmask = bitmask ^ TownDetails.Buildings.BLACKSMITH
		if workshop_toggle.button_pressed:
			bitmask = bitmask ^ TownDetails.Buildings.WORKSHOP
		if lab_toggle.button_pressed:
			bitmask = bitmask ^ TownDetails.Buildings.ALCHEMICAL_LAB
		if hall_toggle.button_pressed:
			bitmask = bitmask ^ TownDetails.Buildings.WONDERS
		
		town_details.buildings_bitmask = bitmask
	else:
		# create new town
		pass
