extends Node

signal settings_value_changed(key: String, new_value, old_value)

const SETTINGS_FILE: String = "user://settings.cfg"
const DEFAULT_SECTION: String = "user"

var config: ConfigFile
var settings: Dictionary = {} # String -> setting


func _init() -> void:
	config = ConfigFile.new()
	config.load(SETTINGS_FILE)


func _ready() -> void:
	# TODO: Find better owner for this
	register_setting("game_locale", "en_US", "locale")
	TranslationServer.set_locale(get_value("game_locale", "locale"))


func register_setting(key: String, default, section: String = DEFAULT_SECTION) -> void:
	if not settings.has(section):
		settings[section] = {}
	
	if not settings[section].has(key):
		settings[section][key] = { "default": default }
	else:
		push_warning("%s is a duplicated setting" % key)


func get_value(key: String, section: String = DEFAULT_SECTION):
	return config.get_value(section, key, _get_default(key, section))


func set_value(key: String, value, section: String = DEFAULT_SECTION) -> void:
	var old_value = get_value(key, section)
	config.set_value(section, key, value)
	config.save(SETTINGS_FILE)
	
	settings_value_changed.emit(key, value, old_value)


func reset_value_to_default(key: String, section: String = DEFAULT_SECTION) -> void:
	set_value(key, _get_default(key, section))


func reset_all_values_to_default(section: String = "") -> void:
	for s in settings.keys():
		if section == "" or s == section:
			for key in settings[section].keys():
				reset_value_to_default(key, section)


func _get_default(key: String, section: String):
	if settings.has(section):
		if settings[section].has(key):
			return settings[section][key]["default"]
	return null
