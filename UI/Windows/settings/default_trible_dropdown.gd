extends OptionButton


func _init() -> void:
	SettingsManager.register_setting("default_tribe", "", "agonia")


func _ready() -> void:
	for index in self.item_count:
		if self.get_item_text(index) == SettingsManager.get_value("default_tribe", "agonia"):
			self.select(index)
			break


func _on_item_selected(index: int) -> void:
	SettingsManager.set_value("default_tribe", self.get_item_text(index), "agonia")
