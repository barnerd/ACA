extends MarginContainer


func _ready() -> void:
	SignalBus.connect_to_signal("on_map_zoom", _on_map_zoom)


func _on_map_zoom(_factor: float) -> void:
	add_theme_constant_override("margin_top", int(24 * _factor + 12))
