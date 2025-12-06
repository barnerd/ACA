extends Window

var current_version: Dictionary = {}
var previous_version: Dictionary = {}

@onready var change_log_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer
@onready var dont_show_checkbox: CheckBox = $PanelContainer/MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/CheckBox


func _init() -> void:
	SettingsManager.register_setting("last_version_seen", {"major": 0, "minor": 0, "release": 0}, "settings")
	#SettingsManager.set_value("last_version_seen", Vector3i(0, 0, 0), "settings")


func _ready() -> void:
	var latest_entry = change_log_container.get_child(0) as ChangeLogEntry
	current_version["major"] = latest_entry.major_version
	current_version["minor"] = latest_entry.minor_version
	current_version["release"] = latest_entry.release_version
	
	var previous_entry = change_log_container.get_child(1) as ChangeLogEntry
	previous_version["major"] = previous_entry.major_version
	previous_version["minor"] = previous_entry.minor_version
	previous_version["release"] = previous_entry.release_version
	
	var last_seen = SettingsManager.get_value("last_version_seen", "settings")
	if _compare_version(current_version, last_seen) > 0:
		for entry in change_log_container.get_children():
			entry.highlight(last_seen)
		
		show()


func _on_close_requested() -> void:
	if dont_show_checkbox.button_pressed:
		SettingsManager.set_value("last_version_seen", current_version, "settings")
	else:
		SettingsManager.set_value("last_version_seen", previous_version, "settings")
	
	hide()


func _compare_version(_a, _b) -> int:
	if _a.major > _b.major:
		return 1
	elif _a.major < _b.major:
		return -1
	else:
		if _a.minor > _b.minor:
			return 1
		elif _a.minor < _b.minor:
			return -1
		else:
			if _a.release > _b.release:
				return 1
			elif _a.release < _b.release:
				return -1
			else:
				return 0
