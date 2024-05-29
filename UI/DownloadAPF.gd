extends Button

var thread: Thread = Thread.new()
var file_to_download: String = ""

@onready var discord_bot_format_checkbox = $"../CheckBox"
signal downloadable_file_progress(progress: float)


func _init() -> void:
	self.disabled = true


func _ready() -> void:
	# TODO: run this on changes, and not on savefile_loaded
	#SignalBus.connect_to_signal("savefile_loaded", Callable(self, "prepare_file").bind(false))
	#SignalBus.connect_to_signal("savefile_loaded", Callable(self, "prepare_file").bind(true))
	pass


func _on_pressed() -> void:
	if discord_bot_format_checkbox.button_pressed:
		download_file("res://Flat Files/agoniaMap2discord.txt", "agoniaMap2")
	else:
		download_file("res://Flat Files/agoniaMap2.txt", "agoniaMap2")


func on_processing_done() -> void:
	self.text = "Download APF File"
	self.disabled = false
	
	# save file to disk
	var save_game_file = FileAccess.open("res://Flat Files/agoniaMap2discord.txt", FileAccess.WRITE)
	save_game_file.store_string(file_to_download)
	save_game_file.close()


func prepare_file_on_thread(_is_for_discord: bool) -> void:
	thread.start(Callable(self, "prepare_file").bind(_is_for_discord), Thread.PRIORITY_LOW)


func prepare_file(_is_for_discord: bool = false) -> void:
	print("preparing apf file")
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
		#print("progress: " + str(100.0 * y / 350) + "%")
		call_deferred("_on_downloadable_file_progress", 100.0 * y / 350)
	
	print("finished preparing apf file")
	call_deferred("on_processing_done")


func download_file(_file: String, _filename: String):
	# load file
	var content: String = ""
	var file = FileAccess.open(_file, FileAccess.READ)
	if file:
		content = file.get_as_text()
	
	var buffer = content.to_ascii_buffer()
	JavaScriptBridge.download_buffer(buffer, "%s.txt" % _filename, "text/plain")


func _exit_tree():
	if thread.is_started():
		thread.wait_to_finish()


func _on_downloadable_file_progress(_progress: float) -> void:
	#print("Preparing - %0.2f%%" % _progress)
	self.text = "Preparing - %0.2f%%" % _progress
