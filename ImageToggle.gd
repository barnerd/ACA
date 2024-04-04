extends CheckButton

@onready var map_layer = $"../../../ScrollContainer/Control/HBoxContainer/PanelContainer/MapImages"

func _on_toggled(toggled_on: bool, _layer: int) -> void:
	map_layer.set_layer_enabled(_layer, toggled_on)
