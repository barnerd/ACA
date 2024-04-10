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
		tier_label.text = "Tier: %s" % encounter_details.tier_name
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


func _update_tile_encounter_id(_tile, _id: String) -> void:
	if _tile.encounter_table_id != _id:
		_tile.encounter_table_id = _id
	MapDetailsSingleton.have_changes_to_save = true


func _on_set_encounter_window_accept() -> void:
	var selection = terrain_options_button.get_selected_id()
	var tier = terrain_options_button.get_item_text(selection)
	
	var terrain_id = tile_details.terrain_id
	
	encounter_details = MonsterDetailsSingleton.encounters_by_terrain_tier[terrain_id][tier]
	
	_update_tile_encounter_id(tile_details, encounter_details.encounter_id)
	
	MonsterDetailsSingleton.encounter_layer.update_labels([tile_details.location])
	update_encounter_details()


func _on_set_encounter_window_fill() -> void:
	var selection = terrain_options_button.get_selected_id()
	var selection_tier = terrain_options_button.get_item_text(selection)
	
	var terrain_id = tile_details.terrain_id
	var starting_encounter = MonsterDetailsSingleton.get_encounter_table_by_id(tile_details.encounter_table_id)
	var starting_tier = -1
	if starting_encounter:
		starting_tier = starting_encounter.tier_number
	var starting_coords = tile_details.location
	
	encounter_details = MonsterDetailsSingleton.encounters_by_terrain_tier[terrain_id][selection_tier]
	var terrain = encounter_details.terrain_id
	var tier = encounter_details.tier_number
	
	# run fill algorithm for list of coords to change
	var region_coords = _get_fill_locations(starting_coords, terrain, starting_tier, tier)
	print("region size: %d" % region_coords.size())
	
	# run through list and change to encounter
	for c in region_coords:
		_update_tile_encounter_id(MapDetailsSingleton.map_tiles[c], encounter_details.encounter_id)
	
	# update encounter layer labels
	MonsterDetailsSingleton.encounter_layer.update_labels(region_coords)
	update_encounter_details()


func _get_fill_locations(_start: Vector3i, _target_terrain: int, _start_tier: int, _target_tier: int, _check_diagonals: bool = false, _mountains_as_same: bool = false) -> Array[Vector3i]:
	var mountain_terrains: Array[int] = [4,5]
	var valid_terrains: Array[int] = [_target_terrain]
	if _mountains_as_same and mountain_terrains.has(_target_terrain):
		valid_terrains = mountain_terrains
	
	# create lists: tiles_to_check, tiles_checked, tiles_in_region
	var tiles_to_check: Array[Vector3i] = []
	var tiles_checked: Array[Vector3i] = []
	var tiles_in_region: Array[Vector3i] = []
	
	# add _start to tiles_to_check
	tiles_to_check.append(_start)
	
	# while tiles_to_check.size() > 0:
	while tiles_to_check:
		assert(tiles_to_check.size() > 0)
		var current_tile_coords = tiles_to_check.pop_back()
		var current_terrain = MapDetailsSingleton.map_tiles[current_tile_coords].terrain_id
		var current_encounter_id = MapDetailsSingleton.map_tiles[current_tile_coords].encounter_table_id
		var current_table = MonsterDetailsSingleton.get_encounter_table_by_id(current_encounter_id)
		var current_tier
		if current_table:
			current_tier = current_table.tier_number
		else:
			current_tier = -1
		
		# check if current is valid tier and same terrain to be in region
		if current_tier != _target_tier and current_tier == _start_tier and valid_terrains.has(current_terrain):
			tiles_in_region.append(current_tile_coords)
		
			# add neighbors
			var neighbor_coords
			neighbor_coords = current_tile_coords + Vector3i.UP + Vector3i.LEFT
			# TODO: Check map boundaries
			if _check_diagonals and not tiles_checked.has(neighbor_coords) and not tiles_to_check.has(neighbor_coords):
				tiles_to_check.append(neighbor_coords)
			
			neighbor_coords = current_tile_coords + Vector3i.UP
			# TODO: Check map boundaries
			if not tiles_checked.has(neighbor_coords) and not tiles_to_check.has(neighbor_coords):
				tiles_to_check.append(neighbor_coords)
			
			neighbor_coords = current_tile_coords + Vector3i.UP + Vector3i.RIGHT
			# TODO: Check map boundaries
			if _check_diagonals and not tiles_checked.has(neighbor_coords) and not tiles_to_check.has(neighbor_coords):
				tiles_to_check.append(neighbor_coords)
			
			neighbor_coords = current_tile_coords + Vector3i.LEFT
			# TODO: Check map boundaries
			if not tiles_checked.has(neighbor_coords) and not tiles_to_check.has(neighbor_coords):
				tiles_to_check.append(neighbor_coords)
			
			neighbor_coords = current_tile_coords + Vector3i.RIGHT
			# TODO: Check map boundaries
			if not tiles_checked.has(neighbor_coords) and not tiles_to_check.has(neighbor_coords):
				tiles_to_check.append(neighbor_coords)
			
			neighbor_coords = current_tile_coords + Vector3i.DOWN + Vector3i.LEFT
			# TODO: Check map boundaries
			if _check_diagonals and not tiles_checked.has(neighbor_coords) and not tiles_to_check.has(neighbor_coords):
				tiles_to_check.append(neighbor_coords)
			
			neighbor_coords = current_tile_coords + Vector3i.DOWN
			# TODO: Check map boundaries
			if not tiles_checked.has(neighbor_coords) and not tiles_to_check.has(neighbor_coords):
				tiles_to_check.append(neighbor_coords)
			
			neighbor_coords = current_tile_coords + Vector3i.DOWN + Vector3i.RIGHT
			# TODO: Check map boundaries
			if _check_diagonals and not tiles_checked.has(neighbor_coords) and not tiles_to_check.has(neighbor_coords):
				tiles_to_check.append(neighbor_coords)
		
		# mark current as checked
		tiles_checked.append(current_tile_coords)
	
	return tiles_in_region
