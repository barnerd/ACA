extends OptionButton


func _init() -> void:
	SettingsManager.register_setting("use_default_tribe", true, "agonia")


func _ready() -> void:
	if SettingsManager.get_value("use_default_tribe", "agonia"):
		self.select(0)


func _on_item_selected(index: int) -> void:
	SettingsManager.set_value("use_default_tribe", index == 0, "agonia")
	print(SettingsManager.get_value("use_default_tribe", "agonia"))
