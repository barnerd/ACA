extends PanelContainer

@onready var watchtower_options = $"MarginContainer/VBoxContainer/Watchtower view/Watchtower OptionButton"
@onready var dwelling_options = $"MarginContainer/VBoxContainer/Dwellings/Dwellings OptionButton"
var view_settings = {"watchtower": 0, "dwelling": 0, "blacksmith": false, "workshop": false, "lab": false, "hall": false}

signal town_view_settings_changed(_settings)


func _init() -> void:
	SignalBus.register_signal("town_view_settings_changed", town_view_settings_changed)


func _on_watchtower_option_button_item_selected(index: int) -> void:
	view_settings["watchtower"] = watchtower_options.get_item_id(index)
	town_view_settings_changed.emit(view_settings)


func _on_dwellings_option_button_item_selected(index: int) -> void:
	view_settings["dwelling"] = dwelling_options.get_item_id(index)
	town_view_settings_changed.emit(view_settings)


func _on_blacksmith_toggled(toggled_on: bool) -> void:
	view_settings["blacksmith"] = toggled_on
	town_view_settings_changed.emit(view_settings)


func _on_workshop_toggled(toggled_on: bool) -> void:
	view_settings["workshop"] = toggled_on
	town_view_settings_changed.emit(view_settings)


func _on_lab_toggled(toggled_on: bool) -> void:
	view_settings["lab"] = toggled_on
	town_view_settings_changed.emit(view_settings)


func _on_hall_toggled(toggled_on: bool) -> void:
	view_settings["hall"] = toggled_on
	town_view_settings_changed.emit(view_settings)


func _on_header_toggled(toggled_on: bool) -> void:
	$"MarginContainer/VBoxContainer/Watchtower view".visible = toggled_on
	$MarginContainer/VBoxContainer/Dwellings.visible = toggled_on
	$"MarginContainer/VBoxContainer/Buildings Label".visible = toggled_on
	$MarginContainer/VBoxContainer/Blacksmith.visible = toggled_on
	$MarginContainer/VBoxContainer/Workshop.visible = toggled_on
	$MarginContainer/VBoxContainer/Lab.visible = toggled_on
	$MarginContainer/VBoxContainer/Hall.visible = toggled_on
