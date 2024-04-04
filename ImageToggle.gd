extends CheckButton

@onready var map_layer = $"../../ScrollContainer/Control/HBoxContainer/PanelContainer/MapImages"

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		map_layer.show()
	else:
		map_layer.hide()
