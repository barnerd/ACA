extends CheckButton

signal show_grid_layer_toggled(_pressed: bool)


func _init() -> void:
	SignalBus.register_signal("show_grid_layer_toggled", show_grid_layer_toggled)


func _on_toggled(toggled_on: bool) -> void:
	show_grid_layer_toggled.emit(toggled_on)
