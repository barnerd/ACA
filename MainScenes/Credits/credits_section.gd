extends VBoxContainer

@export var header_text: String = "Header"
@export_multiline var section_text: String = "section text goes here..."

@onready var header_label: Label = $Header
@onready var section_label: Label = $Section


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	header_label.text = header_text
	section_label.text = section_text
