extends OptionButton

signal tribe_selected(_tribe: String)


func _init() -> void:
	SignalBus.register_signal("tribe_selected", tribe_selected)


func _on_item_selected(index: int) -> void:
	#print("Dropdown emiiter: " + get_item_text(index))
	tribe_selected.emit(get_item_text(index))
