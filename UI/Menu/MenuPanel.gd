extends MarginContainer


func _ready() -> void:
	SignalBus.connect_to_signal("on_map_zoom", _on_map_zoom)


func _on_map_zoom(_factor: float, _old_factor: float) -> void:
	add_theme_constant_override("margin_top", int(24 * _factor + 12))


func _on_header_toggled(toggled_on: bool) -> void:
	$"Menu PanelContainer/VBoxContainer/Groups".visible = toggled_on
	$"Menu PanelContainer/VBoxContainer/Recipes".visible = toggled_on
	$"Menu PanelContainer/VBoxContainer/Sorcery".visible = toggled_on
	$"Menu PanelContainer/VBoxContainer/Settings".visible = toggled_on
	$"Menu PanelContainer/VBoxContainer/Downloads".visible = toggled_on
	$"Menu PanelContainer/VBoxContainer/Credits".visible = toggled_on
	
