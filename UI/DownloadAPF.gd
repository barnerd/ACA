extends Button

var thread: Thread = Thread.new()
var file_to_download: String = ""

signal downloadable_file_progress(progress: float)


func _init() -> void:
	self.disabled = true


func _ready() -> void:
	SignalBus.connect_to_signal("savefile_loaded", prepare_file_on_thread)


func _on_pressed() -> void:
	download_file(file_to_download, "agoniaMap2")


func on_processing_done() -> void:
	self.text = "Download APF File"
	self.disabled = false


func prepare_file_on_thread() -> void:
	thread.start(prepare_file, Thread.PRIORITY_LOW)


func prepare_file() -> void:
	print("preparing apf file")
	# apf file is:
	# 1	aa	aa	aa	aa	... "\r\n"
	file_to_download = ""
	for y in range(1, 350+1):
		file_to_download += str(y)
		for x in range(1, 350+1):
			file_to_download += "\t"
			
			# get terrain id and converter from internal to APF
			var terrain_id: int = MapDetailsSingleton.map_tiles[Vector3i(x, y, 0)].terrain_id
			terrain_id = MapDetailsSingleton.terrain_id_from_internal_to_apf[terrain_id]

			file_to_download += str(terrain_id)
		file_to_download += "\r\n"
		#print("progress: " + str(100.0 * y / 350) + "%")
		call_deferred("_on_downloadable_file_progress", 100.0 * y / 350)
	
	print("finished preparing apf file")
	call_deferred("on_processing_done")


func download_file(_file: String, _filename: String):
	print("Downloading image " + _filename + ".txt")
	var buffer = _file.to_ascii_buffer()
	JavaScriptBridge.download_buffer(buffer, "%s.txt" % _filename, "text/plain")


func _exit_tree():
	if thread.is_started():
		thread.wait_to_finish()


func _on_downloadable_file_progress(_progress: float) -> void:
	#print("Preparing - %0.2f%%" % _progress)
	self.text = "Preparing - %0.2f%%" % _progress
