class_name PathfindingDetails extends VBoxContainer

@onready var x_label = $"HBoxContainer/Left Column/Start Point/X"
@onready var y_label = $"HBoxContainer/Left Column/Start Point/Y"


func _ready() -> void:
	SignalBus.connect_signal("tilemap_location_clicked", on_tilemap_location_clicked)


func on_tilemap_location_clicked(_coords: Vector3i, _button: MouseButton):
	if _button == MOUSE_BUTTON_LEFT:
		x_label.text = str(_coords.x)
		y_label.text = str(_coords.y)
