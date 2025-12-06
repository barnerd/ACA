extends Control

func _ready() -> void:
	SignalBus.connect_to_signal("on_map_zoom", on_map_zoom)


func on_map_zoom(_factor: float, _old_factor: float) -> void:
	self.custom_minimum_size = AgoniaData.MapData.MAP_SIZE.x * AgoniaData.MapData.TILE_SIZE.x * Vector2.ONE * _factor
