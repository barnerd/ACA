extends Window

@onready var terrain_label = $"PanelContainer/VBoxContainer/Terrain & Tier/Terrain Label"
@onready var tier_options_button = $"PanelContainer/VBoxContainer/Terrain & Tier/OptionButton"
@onready var both_mounts_toggle = $PanelContainer/VBoxContainer/BothMountToggle
@onready var diagonals_toggle = $PanelContainer/VBoxContainer/DiagonalsToggle
@onready var reset_toggle = $PanelContainer/VBoxContainer/ResetToggle

# rect fields
@onready var rect_start_x_edit = $"PanelContainer/VBoxContainer/Start HBoxContainer/X Edit"
@onready var rect_start_y_edit = $"PanelContainer/VBoxContainer/Start HBoxContainer/Y Edit"
@onready var rect_end_x_edit = $"PanelContainer/VBoxContainer/End HBoxContainer/X Edit"
@onready var rect_end_y_edit = $"PanelContainer/VBoxContainer/End HBoxContainer/Y Edit"


var encounter_details
var tile_details
var tier_options_current_terrain: int = -1


signal set_encounter_window_accepted(tier: String, use_fill: bool, use_rect: bool, mounts: bool, diagonals: bool, region: Rect2i)


func _init() -> void:
	SignalBus.register_signal("set_encounter_window_accepted", set_encounter_window_accepted)


func _ready() -> void:
	SignalBus.connect_to_signal("tilemap_location_clicked", on_tilemap_location_clicked)


func on_tilemap_location_clicked(_coords: Vector3i, _button: MouseButton):
	if _button == MOUSE_BUTTON_LEFT:
		tile_details = AgoniaData.MapData.map_tiles[_coords]
		encounter_details = AgoniaData.MonsterData.get_encounter_table_by_id(tile_details.encounter_table_id)


func prepare_set_encounter_window() -> void:
	if tile_details:
		var terrain_id = tile_details.terrain_id
		var dropdown_tiers: Array = []
		var dropdown_update: bool = false
		
		if not tier_options_current_terrain == terrain_id:
			tier_options_current_terrain = terrain_id
			dropdown_update = true
			
			var dropdown_terrain: int = terrain_id
			
			# if terrain_id is road, then use plains T1
			if terrain_id == 8:
				dropdown_terrain = 7
				dropdown_tiers = ["T1"]
			# if terrain_id is wastes, include lava
			elif terrain_id == 13:
				# take wastes tiers and lava tiers and combine them
				if AgoniaData.MonsterData.encounters_by_terrain_tier.has(3):
					dropdown_tiers = AgoniaData.MonsterData.encounters_by_terrain_tier[3].keys()
					for t in dropdown_tiers.size():
						dropdown_tiers[t] += " - Lava"
				if AgoniaData.MonsterData.encounters_by_terrain_tier.has(dropdown_terrain):
					dropdown_tiers += AgoniaData.MonsterData.encounters_by_terrain_tier[dropdown_terrain].keys()
			else:
				# if terrain_id is mountain L2, set to mountain L1
				if terrain_id == 5:
					dropdown_terrain = 4
				# if terrain is icy L1, set to snow
				if terrain_id == 10:
					dropdown_terrain = 9
				
				if AgoniaData.MonsterData.encounters_by_terrain_tier.has(dropdown_terrain):
					dropdown_tiers = AgoniaData.MonsterData.encounters_by_terrain_tier[dropdown_terrain].keys()
			
			dropdown_tiers.sort_custom(sort_tier_dropdown)
		
		terrain_label.text = "%s:" % tile_details.terrain_details.terrain_name
		
		rect_start_x_edit.text = str(tile_details.location.x)
		rect_start_y_edit.text = str(tile_details.location.y)
		
		if dropdown_update:
			tier_options_button.clear()
			
			for t in dropdown_tiers:
				tier_options_button.add_item(t)
		
		show()


func sort_tier_dropdown(a: String, b: String) -> bool:
	var a_number = int(a.split(" ")[0].right(-1))
	var b_number = int(b.split(" ")[0].right(-1))
	if a_number == b_number:
		return a < b
	else:
		return a_number < b_number


func _on_fill_button_pressed() -> void:
	_emit_accepted_signal(true)


func _on_accept_button_pressed() -> void:
	_emit_accepted_signal(false)


func _on_rect_button_pressed() -> void:
	# TODO: ensure textEdits are actually ints
	var start_point: Vector2i = Vector2i(int(rect_start_x_edit.text), int(rect_start_y_edit.text))
	var end_point: Vector2i = Vector2i(int(rect_end_x_edit.text), int(rect_end_y_edit.text))
	var rect_size: Vector2i = end_point - start_point
	var rect: Rect2i = Rect2i(start_point, rect_size)
	
	_emit_accepted_signal(false, true, rect)


func _emit_accepted_signal(_use_fill: bool, _use_rect: bool = false, _region: Rect2i = Rect2i()) -> void:
	var target_tier = _get_tier_options_selection()
	
	if reset_toggle.button_pressed:
		target_tier = ""
	
	set_encounter_window_accepted.emit(target_tier, _use_fill, _use_rect, both_mounts_toggle.button_pressed, diagonals_toggle.button_pressed, _region)


func _get_tier_options_selection() -> String:
	var selection_id = tier_options_button.get_selected_id()
	var selection_string = tier_options_button.get_item_text(selection_id)
	
	return selection_string
