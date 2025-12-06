extends OptionButton

var locales: PackedStringArray


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	locales = TranslationServer.get_loaded_locales()
	
	for l in range(0, locales.size()):
		# This shows locales only in English
		# https://github.com/godotengine/godot-proposals/issues/2378
		add_item(TranslationServer.get_locale_name(locales[l]), l)
	
	var current_locale = SettingsManager.get_value("game_locale", "locale")
	
	if not locales.find(current_locale) == -1:
		select(get_item_index(locales.find(current_locale)))
	else:
		print("%s locale not found" % current_locale)


func _on_item_selected(index: int) -> void:
	var new_locale: String = locales[index]
	
	TranslationServer.set_locale(new_locale)
	SettingsManager.set_value("game_locale", new_locale, "locale")
