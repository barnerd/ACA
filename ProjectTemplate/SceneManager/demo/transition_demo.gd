extends Control


func _on_button_pressed() -> void:
	SceneManager.load_scene("res://ProjectTemplate/SceneManager/demo/transition_demo.tscn", "black_fade")
