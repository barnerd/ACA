class_name EncounterDetailsDisplay extends VBoxContainer

var monster_display = preload("res://Details Modules/monster_details_display.tscn")

@onready var section_header = $CenterContainer/RichTextLabel
@onready var monster_header = $VBoxContainer/HBoxContainer
@onready var terrain_label = $"HBoxContainer/Terrain Label"
@onready var tier_label = $"HBoxContainer/Tier Label"
@onready var set_encounter_window_terrain_label = $"Edit Button/Window/VBoxContainer/RichTextLabel"
@onready var terrain_options_button = $"Edit Button/Window/VBoxContainer/OptionButton"

var encounter_details
var tile_details


func _ready() -> void:
	SignalBus.connect_to_signal("tilemap_location_clicked", on_tilemap_location_clicked)


func on_tilemap_location_clicked(_coords: Vector3i, _button: MouseButton):
	if _button == MOUSE_BUTTON_LEFT:
		tile_details = MapDetailsSingleton.map_tiles[_coords]
		encounter_details = MonsterDetailsSingleton.get_encounter_table_by_id(tile_details.encounter_table_id)
		
		update_encounter_details()


func update_encounter_details() -> void:
	# Clear monsters
	for n in $VBoxContainer.get_children():
		if not n.scene_file_path.is_empty():
			n.queue_free()
	
	if encounter_details:
		terrain_label.text = "Terrain: %s" % MapDetailsSingleton.terrains_by_id[encounter_details.terrain_id].terrain_name
		tier_label.text = "Tier: %s" % encounter_details.tier
		$"Edit Button".text = "Edit Encounter"
		# Display nickname
		if encounter_details.nickname:
			section_header.text = "Monster Details - %s" % encounter_details.nickname
		
		# Display monsters
		if encounter_details.monsters:
			monster_header.visible = true
			for m_id in encounter_details.monsters:
				var instance = monster_display.instantiate()
				instance.update(MonsterDetailsSingleton.monsters_by_id[m_id])
				$VBoxContainer.add_child(instance)
		else:
			monster_header.visible = false
	else:
		# No encounter details found
		print("No encounter details found")
		terrain_label.text = "Terrain:"
		tier_label.text = "Tier:"
		$"Edit Button".text = "Add Encounter"



func _prepare_set_encounter_window() -> void:
	if tile_details:
		var terrain_id = tile_details.terrain_id
		
		set_encounter_window_terrain_label.text = tile_details.terrain_details.terrain_name + ":"
		
		terrain_options_button.clear()
		
		if MonsterDetailsSingleton.encounters_by_terrain_tier.has(terrain_id):
			var tiers = MonsterDetailsSingleton.encounters_by_terrain_tier[terrain_id].keys()
			print(tiers)
			for t in tiers:
				terrain_options_button.add_item(t)
		
		$"Edit Button/Window".show()


func _on_set_encounter_window_accept() -> void:
	var selection = terrain_options_button.get_selected_id()
	var tier = terrain_options_button.get_item_text(selection)
	
	var terrain_id = tile_details.terrain_id
	
	encounter_details = MonsterDetailsSingleton.encounters_by_terrain_tier[terrain_id][tier]
	
	if tile_details.encounter_table_id != encounter_details.encounter_id:
		tile_details.encounter_table_id = encounter_details.encounter_id
		MapDetailsSingleton.have_changes_to_save = true
	
	update_encounter_details()


func _on_set_encounter_window_fill() -> void:
	var selection = terrain_options_button.get_selected_id
	var tier = terrain_options_button.get_item_text(selection)
	
	print(tier)
