extends Button

var file_to_download: String = ""

@onready var discord_bot_format_checkbox = $"../CheckBox"


func _ready() -> void:
	SignalBus.connect_to_signal("save_game_requested", on_save_game_requested)


func on_save_game_requested() -> void:
	prepare_file(false)
	prepare_file(true)


func _on_pressed() -> void:
	if discord_bot_format_checkbox.button_pressed:
		download_file("res://Flat Files/agoniaMap2discord.txt", "agoniaMap2")
	else:
		download_file("res://Flat Files/agoniaMap2.txt", "agoniaMap2")


func on_processing_done(_is_for_discord: bool) -> void:
	# save file to disk
	var filename: String
	if _is_for_discord:
		filename = "agoniaMap2discord"
	else:
		filename = "agoniaMap2"
	var save_game_file = FileAccess.open("res://Flat Files/%s.txt" % filename, FileAccess.WRITE)
	save_game_file.store_string(file_to_download)
	save_game_file.close()
	print("%s.txt saved" % filename)


func prepare_file(_is_for_discord: bool = false) -> void:
	print("preparing apf file: " + str(_is_for_discord))
	# apf file is:
	# 1	aa	aa	aa	aa	... "\r\n"
	file_to_download = ""
	for y in range(1, 350+1):
		if not _is_for_discord:
			file_to_download += str(y)
		for x in range(1, 350+1):
			if not _is_for_discord or x != 1:
				file_to_download += "\t"
			
			# get terrain id and converter from internal to APF
			var terrain_id: int = AgoniaData.MapData.map_tiles[Vector3i(x, y, 0)].terrain_id
			terrain_id = TerrainType.TERRAIN_ID_INTERNAL_TO_APF[terrain_id]

			file_to_download += str(terrain_id)
		file_to_download += "\r\n"
		print("progress: " + str(100.0 * y / 350) + "%")
	
	print("finished preparing apf file: " + str(_is_for_discord))
	
	on_processing_done(_is_for_discord)


func download_file(_file: String, _filename: String):
	# load file
	var content: String = ""
	var file = FileAccess.open(_file, FileAccess.READ)
	if file:
		content = file.get_as_text()
	
	var buffer = content.to_ascii_buffer()
	JavaScriptBridge.download_buffer(buffer, "%s.txt" % _filename, "text/plain")
