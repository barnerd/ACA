extends OptionButton

signal tribe_selected(_tribe: String)


func _init() -> void:
	SignalBus.register_signal("tribe_selected", tribe_selected)
	
	SettingsManager.register_setting("selected_tribe", "", "agonia")


func _ready() -> void:
	if SettingsManager.get_value("use_default_tribe", "agonia"):
		select(_find_tribe_index(SettingsManager.get_value("default_tribe", "agonia")))
		_select_tribe(SettingsManager.get_value("default_tribe", "agonia"))
	else:
		select(_find_tribe_index(SettingsManager.get_value("selected_tribe", "agonia")))


func _on_item_selected(index: int) -> void:
	_select_tribe(get_item_text(index))


func _select_tribe(_tribe: String) -> void:
	SettingsManager.set_value("selected_tribe", _tribe, "agonia")
	
	tribe_selected.emit(_tribe)


func _find_tribe_index(_tribe: String) -> int:
	for index in self.item_count:
		if get_item_text(index) == _tribe:
			return index
	return -1
