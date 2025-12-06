extends OptionButton

signal tribe_selected(_tribe: String)


func _init() -> void:
	SignalBus.register_signal("tribe_selected", tribe_selected)
	
	SettingsManager.register_setting("selected_tribe", "", "agonia")
	SettingsManager.register_setting("selected_tribe_index", 5, "agonia")


func _ready() -> void:
	# TODO: use last selected or default?
	select(SettingsManager.get_value("selected_tribe_index", "agonia"))


func _on_item_selected(index: int) -> void:
	SettingsManager.set_value("selected_tribe_index", index, "agonia")
	_select_tribe(get_item_text(index))


func _select_tribe(_tribe: String) -> void:
	SettingsManager.set_value("selected_tribe", _tribe, "agonia")
	
	tribe_selected.emit(_tribe)
