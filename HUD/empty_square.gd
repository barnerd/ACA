extends MarginContainer


func _ready() -> void:
	SignalBus.connect_to_signal("on_map_zoom", on_map_zoom)


func on_map_zoom(_factor: float, _old_factor: float) -> void:
	if _factor < 1.0:
		self.visible = false
	else:
		self.visible = true
		
		self.add_theme_constant_override("margin_left", AgoniaData.MapData.TILE_SIZE.x * _factor)
