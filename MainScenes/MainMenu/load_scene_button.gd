extends Button

@export var scene_path: String


func _on_pressed() -> void:
	SceneManager.load_scene(scene_path)
