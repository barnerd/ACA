class_name EncounterDetailsDisplay extends VBoxContainer

signal encounters_updated(_coords: Array[Vector3i])

var monster_display = preload("res://UI/Details Modules/monster_details_display.tscn")

@onready var section_header = $"CenterContainer/Section Header"
@onready var monster_header = $ScrollContainer/VBoxContainer/HBoxContainer
@onready var monster_section = $ScrollContainer/VBoxContainer
@onready var terrain_label = $"HBoxContainer/Terrain Label"
@onready var tier_label = $"HBoxContainer/Tier Label"
#@onready var set_encounter_window = $"Edit Button/SetEncounterWindow"

var encounter_details
var tile_details


func _init() -> void:
	SignalBus.register_signal("encounters_updated", encounters_updated)


func _ready() -> void:
	SignalBus.connect_to_signal("tilemap_location_clicked", on_tilemap_location_clicked)
	SignalBus.connect_to_signal("set_encounter_window_accepted", on_set_encounter_window_accepted)


func on_tilemap_location_clicked(_coords: Vector3i, _button: MouseButton):
	if _button == MOUSE_BUTTON_LEFT:
		tile_details = AgoniaData.MapData.map_tiles[_coords]
		encounter_details = AgoniaData.MonsterData.get_encounter_table_by_id(tile_details.encounter_table_id)
		
		update_encounter_details()


func update_encounter_details() -> void:
	# Clear monsters
	for n in monster_section.get_children():
		if not n.scene_file_path.is_empty():
			n.queue_free()
	
	if encounter_details:
		terrain_label.text = "Terrain: %s" % AgoniaData.MapData.terrains_by_id[encounter_details.terrain_id].terrain_name
		tier_label.text = "Tier: %s" % encounter_details.tier_name

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
				instance.update(AgoniaData.MonsterData.monsters_by_id[m_id])
				monster_section.add_child(instance)
		else:
			monster_header.visible = false
	else:
		# No encounter details found
		print("No encounter details found")
		terrain_label.text = "Terrain:"
		tier_label.text = "Tier:"


func sort_monsters_in_table(a: int, b: int) -> bool:
	var mon_a = AgoniaData.MonsterData.monsters_by_id[a]
	var mon_b = AgoniaData.MonsterData.monsters_by_id[b]
	
	if mon_a.monster_category == mon_b.monster_category:
		return mon_a.sorcery_requirement < mon_b.sorcery_requirement
	else:
		return mon_a.monster_category < mon_b.monster_category


func _update_tile_encounter_id(_tile, _encounter) -> void:
	if _encounter:
		if _tile.encounter_table_id != _encounter.encounter_id:
			_tile.encounter_table_id = _encounter.encounter_id
	else:
		_tile.encounter_table_id = ""
	AgoniaData.MapData.have_changes_to_save = true


func on_set_encounter_window_accepted(_tier: String, _use_fill: bool, _use_rect: bool, _mounts: bool, _diagonals: bool, _region: Rect2i) -> void:
	var update_encounter_labels: Array[Vector3i] = []
	
	if _tier:
		# use different terrain_id's tables
		if tile_details.terrain_id == 5:
			encounter_details = AgoniaData.MonsterData.encounters_by_terrain_tier[4][_tier]
		elif tile_details.terrain_id == 10:
			encounter_details = AgoniaData.MonsterData.encounters_by_terrain_tier[9][_tier]
		elif tile_details.terrain_id == 8:
			encounter_details = AgoniaData.MonsterData.encounters_by_terrain_tier[7][_tier]
		elif tile_details.terrain_id == 13:
			# if tier is lava, strip lava and use that
			if _tier.right(4) == "Lava":
				_tier = _tier.left(-7)
				encounter_details = AgoniaData.MonsterData.encounters_by_terrain_tier[3][_tier]
			else:
				encounter_details = AgoniaData.MonsterData.encounters_by_terrain_tier[tile_details.terrain_id][_tier]
		else:
			encounter_details = AgoniaData.MonsterData.encounters_by_terrain_tier[tile_details.terrain_id][_tier]
	else:
		encounter_details = null
	
	if _use_fill:
		update_encounter_labels = _set_encounter_for_current_fill(tile_details.terrain_id, _diagonals, _mounts)
	elif _use_rect:
		update_encounter_labels = _set_encounter_for_current_region(tile_details.terrain_id, _region, _mounts)
	else:
		update_encounter_labels = _set_encounter_for_current_tile(tile_details.terrain_id)
	
	print("region size: %d" % update_encounter_labels.size())
	
	# update encounter layer labels
	#AgoniaData.MonsterData.encounter_layer.update_labels(update_encounter_labels)
	encounters_updated.emit(update_encounter_labels)
	update_encounter_details()


func _set_encounter_for_current_tile(_terrain_id: int) -> Array[Vector3i]:
	_update_tile_encounter_id(tile_details, encounter_details)
	
	return [tile_details.location]


func _set_encounter_for_current_fill(_terrain_id: int, _check_diagonals: bool = false, _mountains_as_same: bool = false) -> Array[Vector3i]:
	var starting_encounter = AgoniaData.MonsterData.get_encounter_table_by_id(tile_details.encounter_table_id)
	var starting_tier = -1
	if starting_encounter:
		starting_tier = starting_encounter.tier_number
	var starting_coords = tile_details.location
	
	var target_tier = -1
	if encounter_details:
		target_tier = encounter_details.tier_number
	
	# run fill algorithm for list of coords to change
	var region_coords = _get_fill_locations(starting_coords, _terrain_id, starting_tier, target_tier, _check_diagonals, _mountains_as_same)
	
	# run through list and change to encounter
	for c in region_coords:
		_update_tile_encounter_id(AgoniaData.MapData.map_tiles[c], encounter_details)
	
	return region_coords


func _set_encounter_for_current_region(_terrain_id: int, _region: Rect2i, _mountains_as_same: bool = false) -> Array[Vector3i]:
	var region_coords: Array[Vector3i] = []
	
	var mountain_terrains: Array[int] = [4,5]
	var valid_terrains: Array[int] = [_terrain_id]
	if _mountains_as_same and mountain_terrains.has(_terrain_id):
		valid_terrains = mountain_terrains
	
	for y in _region.size.y+1:
		for x in _region.size.x+1:
			var point: Vector3i = Vector3i(_region.position.x + x, _region.position.y + y, 0)
			
			# TODO: Pass include mountains and check both terrain ids
			# get terrain_id at point
			var current_terrain = AgoniaData.MapData.map_tiles[point].terrain_id
			
			# if it matches _terrain_id, then update and add to list
			if valid_terrains.has(current_terrain):
				pass
				region_coords.append(point)
				_update_tile_encounter_id(AgoniaData.MapData.map_tiles[point], encounter_details)
	
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
		var current_terrain = AgoniaData.MapData.map_tiles[current_tile_coords].terrain_id
		var current_encounter_id = AgoniaData.MapData.map_tiles[current_tile_coords].encounter_table_id
		var current_table = AgoniaData.MonsterData.get_encounter_table_by_id(current_encounter_id)
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
