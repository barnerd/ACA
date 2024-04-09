extends Button

var thread: Thread = Thread.new()
var file_to_download: Image = Image.new()


func _init() -> void:
	pass #self.disabled = true


func _ready() -> void:
	pass
	#thread.start(prepare_file, Thread.PRIORITY_LOW)


func _on_pressed() -> void:
	pass
	#download_file(file_to_download, "agoniaMap2")


func on_processing_done():
	pass #self.disabled = false


func prepare_file() -> void:
	
	
	call_deferred("on_processing_done")


func download_file(_file: Image, _filename: String):
	print("Downloading image " + _filename + ".txt")
	var buffer = _file.save_png_to_buffer()
	JavaScriptBridge.download_buffer(buffer, "%s.txt" % _filename, "text/plain")


func _exit_tree():
	thread.wait_to_finish()
