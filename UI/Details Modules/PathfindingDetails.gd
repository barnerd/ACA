class_name PathfindingDetails extends PanelContainer

@onready var start_x_label = $"MarginContainer/VBoxContainer/HBoxContainer/Left Column/Start Point/X"
@onready var start_y_label = $"MarginContainer/VBoxContainer/HBoxContainer/Left Column/Start Point/Y"
@onready var end_x_label = $"MarginContainer/VBoxContainer/HBoxContainer/Left Column/End Point/X"
@onready var end_y_label = $"MarginContainer/VBoxContainer/HBoxContainer/Left Column/End Point/Y"
@onready var pathfinder = $"MarginContainer/VBoxContainer/Calculate Button/Pathfinder"


func _ready() -> void:
	SignalBus.connect_to_signal("tilemap_location_clicked", on_tilemap_location_clicked)


func on_tilemap_location_clicked(_coords: Vector3i, _button: MouseButton):
	if _button == MOUSE_BUTTON_LEFT:
		start_x_label.text = str(_coords.x)
		start_y_label.text = str(_coords.y)
		pathfinder.start_point = Vector2i(_coords.x, _coords.y)
	elif  _button == MOUSE_BUTTON_RIGHT:
		end_x_label.text = str(_coords.x)
		end_y_label.text = str(_coords.y)
		pathfinder.end_point = Vector2i(_coords.x, _coords.y)


func _on_section_header_toggled(toggled_on: bool) -> void:
	$MarginContainer/VBoxContainer/HBoxContainer.visible = toggled_on
	$MarginContainer/VBoxContainer/Spacer.visible = toggled_on
	$"MarginContainer/VBoxContainer/Calculate Button".visible = toggled_on
	$"MarginContainer/VBoxContainer/Clear Path Button".visible = toggled_on
