extends Window

@onready var terrain_label = $"VBoxContainer/Terrain & Tier/Terrain Label"
@onready var tier_options_button = $"VBoxContainer/Terrain & Tier/OptionButton"
@onready var both_mounts_toggle = $VBoxContainer/BothMountToggle
@onready var diagonals_toggle = $VBoxContainer/DiagonalsToggle
@onready var reset_toggle = $VBoxContainer/ResetToggle

# rect fields
@onready var rect_start_x_edit = $"VBoxContainer/Start HBoxContainer/X Edit"
@onready var rect_start_y_edit = $"VBoxContainer/Start HBoxContainer/Y Edit"
@onready var rect_end_x_edit = $"VBoxContainer/End HBoxContainer/X Edit"
@onready var rect_end_y_edit = $"VBoxContainer/End HBoxContainer/Y Edit"


signal set_encounter_window_accepted(tier: String, use_fill: bool, use_rect: bool, mounts: bool, diagonals: bool, region: Rect2i)


func _init() -> void:
	SignalBus.register_signal("set_encounter_window_accepted", set_encounter_window_accepted)


func prepare_set_encounter_window(_terrain_name: String, _dropdown_tiers: Array, _location: Vector3i, dropdown_update: bool = false) -> void:
	terrain_label.text = "%s:" % _terrain_name
	
	rect_start_x_edit.text = str(_location.x)
	rect_start_y_edit.text = str(_location.y)
	
	if dropdown_update:
		tier_options_button.clear()
		
		for t in _dropdown_tiers:
			tier_options_button.add_item(t)


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
