extends Window

@onready var text_box = $PanelContainer/MarginContainer/VBoxContainer/TextEdit
@onready var status_label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Status

var regex: RegEx
var map_table_data: String


func _init() -> void:
	regex = RegEx.new()


func _on_update_map_button_pressed() -> void:
	self.show()


func _on_parse_button_pressed() -> void:
	self.hide()


func _on_text_edit_text_changed() -> void:
	# check for <table> tag, and anything else
	# \\s\\S for multiline
	# /? to match /
	regex.compile("<table>([./n/r\\s\\S]*)</?table>")

	var result = regex.search(text_box.text)
	if result:
		map_table_data = result.get_string(1)
		status_label.text = "<table> tag detected"
	else:
		status_label.text = "No <table> tag"


func _on_order_side_button_pressed() -> void:
	self.show()
