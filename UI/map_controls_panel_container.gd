extends PanelContainer


func _on_header_toggled(toggled_on: bool) -> void:
	$"MarginContainer/VBoxContainer/Encounters Layer Toggle".visible = toggled_on
	$"MarginContainer/VBoxContainer/Min Encounter Tier".visible = toggled_on
	$"MarginContainer/VBoxContainer/Image toggle".visible = toggled_on
	$"MarginContainer/VBoxContainer/Image toggle2".visible = toggled_on
	$"MarginContainer/VBoxContainer/Image toggle3".visible = toggled_on
	$"MarginContainer/VBoxContainer/Image toggle4".visible = toggled_on
	$"MarginContainer/VBoxContainer/Grid Layer Toggle".visible = toggled_on
	$"MarginContainer/VBoxContainer/Zoom Controls VBox".visible = toggled_on
