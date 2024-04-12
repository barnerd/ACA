class_name EncounterDetailsDisplay extends VBoxContainer

var monster_display = preload("res://UI/Details Modules/monster_details_display.tscn")

@onready var section_header = $CenterContainer/RichTextLabel
@onready var monster_header = $ScrollContainer/VBoxContainer/HBoxContainer
@onready var monster_section = $ScrollContainer/VBoxContainer
@onready var terrain_label = $"HBoxContainer/Terrain Label"
@onready var tier_label = $"HBoxContainer/Tier Label"
@onready var set_encounter_window_terrain_label = $"Edit Button/SetEncounterWindow/VBoxContainer/RichTextLabel"
@onready var terrain_options_button = $"Edit Button/SetEncounterWindow/VBoxContainer/OptionButton"

var encounter_details
var tile_details
var tier_options_current_terrain: int = -1


func _ready() -> void:
	SignalBus.connect_to_signal("tilemap_location_clicked", on_tilemap_location_clicked)
	SignalBus.connect_to_signal("set_encounter_window_accepted", on_set_encounter_window_accepted)


func on_tilemap_location_clicked(_coords: Vector3i, _button: MouseButton):
	if _button == MOUSE_BUTTON_LEFT:
		tile_details = MapDetailsSingleton.map_tiles[_coords]
		encounter_details = MonsterDetailsSingleton.get_encounter_table_by_id(tile_details.encounter_table_id)
		
		update_encounter_details()


func update_encounter_details() -> void:
	# Clear monsters
	for n in monster_section.get_children():
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
			# TODO: Sort encounter_details.monsters before displaying
			encounter_details.monsters.sort_custom(sort_monsters_in_table)
			for m_id in encounter_details.monsters:
				var instance = monster_display.instantiate()
				instance.update(MonsterDetailsSingleton.monsters_by_id[m_id])
				monster_section.add_child(instance)
		else:
			monster_header.visible = false
	else:
		# No encounter details found
		print("No encounter details found")
		terrain_label.text = "Terrain:"
		tier_label.text = "Tier:"
		$"Edit Button".text = "Add Encounter"


func sort_monsters_in_table(a: int, b: int) -> bool:
	var mon_a = MonsterDetailsSingleton.monsters_by_id[a]
	var mon_b = MonsterDetailsSingleton.monsters_by_id[b]
	
	if mon_a.monster_category == mon_b.monster_category:
		return mon_a.sorcery_requirement < mon_b.sorcery_requirement
	else:
		return mon_a.monster_category < mon_b.monster_category


func _prepare_set_encounter_window() -> void:
	if tile_details:
		var terrain_id = tile_details.terrain_id
		
		set_encounter_window_terrain_label.text = tile_details.terrain_details.terrain_name + ":"
		
		if not tier_options_current_terrain == terrain_id:
			tier_options_current_terrain = terrain_id
			terrain_options_button.clear()
			
			var dropdown_terrain: int = terrain_id
			var droptown_tiers: Array = []
			
			# if terrain_id is road, then use plains T1
			if terrain_id == 8:
				dropdown_terrain = 7
				droptown_tiers = ["T1"]
			# if terrain_id is wastes, include lava
			elif terrain_id == 13:
				# take wastes tiers and lava tiers and combine them
				if MonsterDetailsSingleton.encounters_by_terrain_tier.has(3):
					droptown_tiers = MonsterDetailsSingleton.encounters_by_terrain_tier[3].keys()
					for t in droptown_tiers.size():
						droptown_tiers[t] += " - Lava"
				if MonsterDetailsSingleton.encounters_by_terrain_tier.has(dropdown_terrain):
					droptown_tiers += MonsterDetailsSingleton.encounters_by_terrain_tier[dropdown_terrain].keys()
			else:
				# if terrain_id is mountain L2, set to mountain L1
				if terrain_id == 5:
					dropdown_terrain = 4
				# if terrain is icy L1, set to snow
				if terrain_id == 10:
					dropdown_terrain = 9
				
				if MonsterDetailsSingleton.encounters_by_terrain_tier.has(dropdown_terrain):
					droptown_tiers = MonsterDetailsSingleton.encounters_by_terrain_tier[dropdown_terrain].keys()
			

			droptown_tiers.sort_custom(sort_tier_dropdown)
			for t in droptown_tiers:
				terrain_options_button.add_item(t)
		
		$"Edit Button/SetEncounterWindow".show()


func sort_tier_dropdown(a: String, b: String) -> bool:
	var a_number = int(a.split(" ")[0].right(-1))
	var b_number = int(b.split(" ")[0].right(-1))
	if a_number == b_number:
		return a < b
	else:
		return a_number < b_number


func _update_tile_encounter_id(_tile, _encounter) -> void:
	if _encounter:
		if _tile.encounter_table_id != _encounter.encounter_id:
			_tile.encounter_table_id = _encounter.encounter_id
	else:
		_tile.encounter_table_id = ""
	MapDetailsSingleton.have_changes_to_save = true


func on_set_encounter_window_accepted(_tier: String, _fill: bool, _mounts: bool, _diagonals: bool) -> void:
	var update_encounter_labels: Array[Vector3i] = []
	
	if _tier:
		# use different terrain_id's tables
		if tile_details.terrain_id == 5:
			encounter_details = MonsterDetailsSingleton.encounters_by_terrain_tier[4][_tier]
		elif tile_details.terrain_id == 10:
			encounter_details = MonsterDetailsSingleton.encounters_by_terrain_tier[9][_tier]
		elif tile_details.terrain_id == 8:
			encounter_details = MonsterDetailsSingleton.encounters_by_terrain_tier[7][_tier]
		elif tile_details.terrain_id == 13:
			# if tier is lava, strip lava and use that
			if _tier.right(4) == "Lava":
				_tier = _tier.left(-7)
				encounter_details = MonsterDetailsSingleton.encounters_by_terrain_tier[3][_tier]
			else:
				encounter_details = MonsterDetailsSingleton.encounters_by_terrain_tier[tile_details.terrain_id][_tier]
		else:
			encounter_details = MonsterDetailsSingleton.encounters_by_terrain_tier[tile_details.terrain_id][_tier]
	else:
		encounter_details = null
	
	if _fill:
		update_encounter_labels = _set_encounter_for_current_fill(tile_details.terrain_id, _diagonals, _mounts)
	else:
		update_encounter_labels = _set_encounter_for_current_tile(tile_details.terrain_id)
	
	# update encounter layer labels
	MonsterDetailsSingleton.encounter_layer.update_labels(update_encounter_labels)
	update_encounter_details()


func _set_encounter_for_current_tile(_terrain_id: int) -> Array[Vector3i]:
	_update_tile_encounter_id(tile_details, encounter_details)
	
	return [tile_details.location]


func _set_encounter_for_current_fill(_terrain_id: int, _check_diagonals: bool = false, _mountains_as_same: bool = false) -> Array[Vector3i]:
	var starting_encounter = MonsterDetailsSingleton.get_encounter_table_by_id(tile_details.encounter_table_id)
	var starting_tier = -1
	if starting_encounter:
		starting_tier = starting_encounter.tier_number
	var starting_coords = tile_details.location
	
	var target_tier = -1
	if encounter_details:
		target_tier = encounter_details.tier_number
	
	# run fill algorithm for list of coords to change
	var region_coords = _get_fill_locations(starting_coords, _terrain_id, starting_tier, target_tier, _check_diagonals, _mountains_as_same)
	print("region size: %d" % region_coords.size())
	
	# run through list and change to encounter
	for c in region_coords:
		_update_tile_encounter_id(MapDetailsSingleton.map_tiles[c], encounter_details)
	
	return region_coords


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
