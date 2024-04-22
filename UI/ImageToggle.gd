extends CheckButton

@onready var map_layer = AgoniaData.MapData.tile_map_display

signal tilemap_layer_toggled(_layer:int, _on: bool)


func _init() -> void:
	SignalBus.register_signal("tilemap_layer_toggled", tilemap_layer_toggled)


func _on_toggled(toggled_on: bool, _layer: int) -> void:
	map_layer.set_layer_enabled(_layer, toggled_on)
	tilemap_layer_toggled.emit(_layer, toggled_on)
