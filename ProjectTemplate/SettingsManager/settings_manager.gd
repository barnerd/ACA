extends Node

signal settings_value_changed(key: String, new_value, old_value)

const SETTINGS_FILE_PATH: String = "user://settings.cfg"
const DEFAULT_SECTION: String = "user"

var config: ConfigFile
var settings: Dictionary[String, Variant] = {} # String -> setting
var password = "abcd" # OS.get_unique_id() doesn't work on the web


func _init() -> void:
	config = ConfigFile.new()
	config.load_encrypted_pass(SETTINGS_FILE_PATH, password)


func _ready() -> void:
	# TODO: Find better owner for this
	register_setting("game_locale", "en_US", "locale")
	TranslationServer.set_locale(get_value("game_locale", "locale"))


func register_setting(key: String, default, section: String = DEFAULT_SECTION) -> void:
	if not settings.has(section):
		settings[section] = {}
	
	if not settings[section].has(key):
		settings[section][key] = { "default": default }
		if not config.has_section_key(section, key):
			set_value(key, default, section)
	else:
		push_warning("%s is a duplicated setting" % key)


func _remove_setting(key: String, section: String = DEFAULT_SECTION) -> void:
	if settings.has(section):
		if settings[section].has(key):
			settings[section].erase(key)
			config.erase_section_key(section, key)


func get_value(key: String, section: String = DEFAULT_SECTION):
	return config.get_value(section, key, _get_default(key, section))


func set_value(key: String, value, section: String = DEFAULT_SECTION) -> void:
	var old_value = get_value(key, section)
	config.set_value(section, key, value)
	config.save_encrypted_pass(SETTINGS_FILE_PATH, password)
	
	settings_value_changed.emit(key, value, old_value)


func reset_value_to_default(key: String, section: String = DEFAULT_SECTION) -> void:
	set_value(key, _get_default(key, section), section)


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
