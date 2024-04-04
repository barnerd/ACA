extends PopupPanel

@onready var results_lebel = $VBoxContainer/Results
@onready var status_label  = $VBoxContainer/HBoxContainer/Status


func _on_parse_button_pressed() -> void:
	self.show()


func _on_cancel_button_pressed() -> void:
	self.hide()


func _on_accept_button_pressed() -> void:
	status_label.text = "Making changes..."
	self.hide()
