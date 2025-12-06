extends PanelContainer

func _ready() -> void:
	SignalBus.connect_to_signal("on_map_zoom", on_map_zoom)


func on_map_zoom(_factor: float, _old_factor: float) -> void:
	self.scale = Vector2.ONE * _factor
