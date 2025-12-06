extends Window

@onready var talisman_dropdown = $PanelContainer/Control/TalismanPanel/VBoxContainer/OptionButton
@onready var cape_dropdown = $PanelContainer/Control/CapePanel/VBoxContainer/OptionButton
@onready var boots_dropdown = $PanelContainer/Control/BootPanel/VBoxContainer/OptionButton

signal equipment_changed()


func _init() -> void:
	SignalBus.register_signal("equipment_changed", equipment_changed)
	
	SettingsManager.register_setting("selected_talisman", "None", "equipment")
	SettingsManager.register_setting("selected_cape", "None", "equipment")
	SettingsManager.register_setting("selected_boots", "None", "equipment")


func _ready() -> void:
	for index in talisman_dropdown.item_count:
		if talisman_dropdown.get_item_text(index) == SettingsManager.get_value("selected_talisman", "equipment"):
			talisman_dropdown.select(index)
			break
	
	for index in cape_dropdown.item_count:
		if cape_dropdown.get_item_text(index) == SettingsManager.get_value("selected_cape", "equipment"):
			cape_dropdown.select(index)
			break
	
	for index in boots_dropdown.item_count:
		if boots_dropdown.get_item_text(index) == SettingsManager.get_value("selected_boots", "equipment"):
			boots_dropdown.select(index)
			break


func _on_talisman_item_selected(index: int) -> void:
	SettingsManager.set_value("selected_talisman", talisman_dropdown.get_item_text(index), "equipment")
	equipment_changed.emit()


func _on_cape_item_selected(index: int) -> void:
	SettingsManager.set_value("selected_cape", cape_dropdown.get_item_text(index), "equipment")
	equipment_changed.emit()


func _on_boots_item_selected(index: int) -> void:
	SettingsManager.set_value("selected_boots", boots_dropdown.get_item_text(index), "equipment")
	equipment_changed.emit()
