extends MarginContainer

signal on_groups_menu_button_pressed()
signal on_recipes_menu_button_pressed()
signal on_sorcery_menu_button_pressed()
signal on_settings_menu_button_pressed()
signal on_credits_menu_button_pressed()


func _init() -> void:
	SignalBus.register_signal("on_groups_menu_button_pressed", on_groups_menu_button_pressed)
	SignalBus.register_signal("on_recipes_menu_button_pressed", on_recipes_menu_button_pressed)
	SignalBus.register_signal("on_sorcery_menu_button_pressed", on_sorcery_menu_button_pressed)
	SignalBus.register_signal("on_settings_menu_button_pressed", on_settings_menu_button_pressed)
	SignalBus.register_signal("on_credits_menu_button_pressed", on_credits_menu_button_pressed)


func _ready() -> void:
	SignalBus.connect_to_signal("on_map_zoom", _on_map_zoom)


func _on_map_zoom(_factor: float) -> void:
	add_theme_constant_override("margin_top", int(24 * _factor + 12))


func _on_groups_menu_item_pressed() -> void:
	on_groups_menu_button_pressed.emit()


func _on_recipes_menu_item_pressed() -> void:
	on_recipes_menu_button_pressed.emit()


func _on_sorcery_menu_item_pressed() -> void:
	on_sorcery_menu_button_pressed.emit()


func _on_settings_menu_item_pressed() -> void:
	on_settings_menu_button_pressed.emit()


func _on_credits_menu_item_pressed() -> void:
	on_credits_menu_button_pressed.emit()
