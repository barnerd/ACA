extends Window

@onready var talisman_dropdown = $PanelContainer/Control/TalismanPanel/VBoxContainer/OptionButton
@onready var cape_dropdown = $PanelContainer/Control/CapePanel/VBoxContainer/OptionButton
@onready var boots_dropdown = $PanelContainer/Control/BootPanel/VBoxContainer/OptionButton

var equipment

signal equipment_changed(equipment)


func _init() -> void:
	equipment = {"talisman": "None", "cape": "None", "boots": "None"}
	
	SignalBus.register_signal("equipment_changed", equipment_changed)


func _on_talisman_item_selected(index: int) -> void:
	equipment["talisman"] = talisman_dropdown.get_item_text(index)
	equipment_changed.emit(equipment)


func _on_cape_item_selected(index: int) -> void:
	equipment["cape"] = cape_dropdown.get_item_text(index)
	equipment_changed.emit(equipment)


func _on_boots_item_selected(index: int) -> void:
	equipment["boots"] = boots_dropdown.get_item_text(index)
	equipment_changed.emit(equipment)


func _on_total_weight_text_changed(new_text: String) -> void:
	if new_text.is_valid_int():
		equipment["total_weight"] = int(new_text)
		equipment_changed.emit(equipment)


func _on_max_weight_text_changed(new_text: String) -> void:
	if new_text.is_valid_int():
		equipment["max_weight"] = int(new_text)
		equipment_changed.emit(equipment)
