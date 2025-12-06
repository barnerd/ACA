extends Label


func _ready() -> void:
	SignalBus.connect_to_signal("equipment_changed", on_equipment_changed)
	_update_display()


func on_equipment_changed() -> void:
	_update_display()


func _update_display() -> void:
	var equipment: Array[String] = []
	
	if SettingsManager.get_value("selected_talisman", "equipment") != "None":
		equipment.append(SettingsManager.get_value("selected_talisman", "equipment"))
	
	if SettingsManager.get_value("selected_cape", "equipment") != "None":
		equipment.append(SettingsManager.get_value("selected_cape", "equipment"))
	
	if SettingsManager.get_value("selected_boots", "equipment") != "None":
		equipment.append(SettingsManager.get_value("selected_boots", "equipment"))

	if equipment.size() == 0:
		self.text = "No equipment"
	else:
		self.text = ", ".join(equipment)
