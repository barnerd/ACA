extends PanelContainer

signal scene_loaded(new_scene: Node)
signal midpoint_reached()
signal transitions_finished

@onready var progress_bar = $ProgressBar
@onready var timer = $Timer

var _outgoing_scene: Node
var _incoming_scene_path: String
var _incoming_scene: Node

var _transition: Transition
var _transition_options: Dictionary

var at_midpoint: bool = false
var is_scene_loaded: bool = false


func _process(_delta: float) -> void:
	if not is_scene_loaded:
		_monitor_load_status()


func load_scene(outgoing_scene: Node, incoming_scene_path: String, transition: Transition, options: Dictionary = {}) -> void:
	#print("2. loading_screen load_scene")
	_outgoing_scene = outgoing_scene
	_incoming_scene_path = incoming_scene_path
	_transition = transition
	_transition_options = options
	
	_transition.transitioned_in.connect(_on_transitioned_in)
	_transition.transitioned_out.connect(_on_transitions_finished)
	
	# load incoming_scene
	timer.start()
	var loader = ResourceLoader.load_threaded_request(incoming_scene_path)
	if not ResourceLoader.exists(incoming_scene_path) or loader == null:
		print("%s is an invalid resource path" % incoming_scene_path)
		return
	
	# transition_start()
	_transition.start(self, outgoing_scene, _transition_options)


func _on_transitioned_in() -> void:
	#print("3.5. loading_screen _on_transitioned_in")
	at_midpoint = true
	
	# if both transition in done and scene loaded
	if at_midpoint and is_scene_loaded:
		_on_transition_out_ready()


func _on_scene_loaded() -> void:
	#print("3.5. loading_screen on_scene_loaded")
	is_scene_loaded = true
	scene_loaded.emit(_incoming_scene)
	
	if (
		_outgoing_scene
		and _incoming_scene
		and _outgoing_scene.has_method("get_scene_data")
		and _incoming_scene.has_method("set_scene_data")
	):
		_incoming_scene.set_scene_data(_outgoing_scene.get_scene_data())
	
	# if both transition in done and scene loaded
	if at_midpoint and is_scene_loaded:
		_on_transition_out_ready()


func _on_transition_out_ready() -> void:
	#print("4. loading_screen on_transition_out_ready")
	midpoint_reached.emit()
	# timer to give time to see the midpoint
	#await get_tree().create_timer(2.0).timeout
	_transition.finish(self, _outgoing_scene, _incoming_scene, _transition_options)


func _on_transitions_finished() -> void:
	#print("6. loading_screen on_transitions_finished")
	transitions_finished.emit()
	queue_free()


func _monitor_load_status() -> void:
	var load_progress = []
	var load_status = ResourceLoader.load_threaded_get_status(_incoming_scene_path, load_progress)
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			#_content_invalid.emit(_incoming_scene_path)
			pass
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = load_progress[0] * 100.0
			print("progress: %f%%" % (load_progress[0] * 100.0))
		ResourceLoader.THREAD_LOAD_FAILED:
			#_content_failed_to_load.emit(_content_path)
			pass
		ResourceLoader.THREAD_LOAD_LOADED:
			timer.stop()
			_incoming_scene = ResourceLoader.load_threaded_get(_incoming_scene_path).instantiate()
			_on_scene_loaded()


func _on_timer_timeout() -> void:
	progress_bar.visible = true
