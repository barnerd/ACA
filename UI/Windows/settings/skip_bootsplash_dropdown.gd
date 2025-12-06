extends CheckBox


func _ready() -> void:
	self.button_pressed = SettingsManager.get_value("skip_bootsplash", "SceneManager")


func _on_pressed() -> void:
	SettingsManager.set_value("skip_bootsplash", self.button_pressed, "SceneManager")
