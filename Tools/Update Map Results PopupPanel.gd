extends Window

@onready var results_lebel = $PanelContainer/MarginContainer/VBoxContainer/Results
@onready var status_label  = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Status


func _on_parse_button_pressed() -> void:
	self.show()


func _on_cancel_button_pressed() -> void:
	self.hide()


func _on_accept_button_pressed() -> void:
	status_label.text = "Making changes..."
	self.hide()
