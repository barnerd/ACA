extends Window

@onready var tier_options_button = $VBoxContainer/OptionButton
@onready var both_mounts_toggle = $VBoxContainer/BothMountToggle
@onready var diagonals_toggle = $VBoxContainer/DiagonalsToggle
@onready var reset_toggle = $VBoxContainer/ResetToggle

signal set_encounter_window_accepted(tier: String, fill: bool, mounts: bool, diagonals: bool)


func _init() -> void:
	SignalBus.register_signal("set_encounter_window_accepted", set_encounter_window_accepted)


func _on_fill_button_pressed() -> void:
	_emit_accepted_signal(true)


func _on_accept_button_pressed() -> void:
	_emit_accepted_signal(false)


func _emit_accepted_signal(_fill: bool) -> void:
	var target_tier = _get_tier_options_selection()
	
	if reset_toggle.button_pressed:
		target_tier = ""
	
	set_encounter_window_accepted.emit(target_tier, _fill, both_mounts_toggle.button_pressed, diagonals_toggle.button_pressed)


func _get_tier_options_selection() -> String:
	var selection_id = tier_options_button.get_selected_id()
	var selection_string = tier_options_button.get_item_text(selection_id)
	
	return selection_string
