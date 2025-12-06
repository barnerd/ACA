extends Node

# order matters
@export var bootsplash_paths: Array[String] = [
	"res://ProjectTemplate/SceneManager/BootSplashes/company_logo.tscn",
	"res://ProjectTemplate/SceneManager/BootSplashes/godot_logo.tscn",
	]


func _ready() -> void:
	SceneManager.load_bootsplashes(bootsplash_paths)
