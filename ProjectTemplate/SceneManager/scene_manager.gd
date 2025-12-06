extends Node

var main_menu_scene_path: String = "res://HUD/map_viewer.tscn"

var loading_screen: PackedScene = preload("res://ProjectTemplate/SceneManager/loading_screen.tscn")
var main_menu_scene: PackedScene

var new_game_scene: PackedScene
var main_scene: PackedScene

var bootsplash_paths: Array[String] = []
var bootsplash_index: int

# order doesn't matter
var transition_paths: Array[String] = [
	"res://ProjectTemplate/SceneManager/Transitions/transition.gd", 
	"res://ProjectTemplate/SceneManager/Transitions/blackfade.gd",
	"res://ProjectTemplate/SceneManager/Transitions/colorfade.gd",
	]

var transitions: Dictionary = {} # name: String -> Transition

var _scene_stack: Array[String] = []
var current_scene: Node


# load and preload scenes, 
# Transition between them
# has many transition types
# Has ability to get back to previous scene
# Can load scenes into place, or switch to them completely
# (i.e. don’t remove hud, or add a window)

func _init() -> void:
	# run through transitions folder
	# load all transitions
	for file in transition_paths:
		var new_transition = load(file).new()
		if new_transition is Transition and not transitions.has(new_transition.transition_name):
			transitions[new_transition.transition_name] = new_transition
	
	# TODO: Make sure SettingsManager is loaded first
	SettingsManager.register_setting("skip_bootsplash", false, "SceneManager")


func load_bootsplashes(_bootsplash_paths: Array[String]) -> void:
	bootsplash_paths = _bootsplash_paths
	
	# run through BootSplashes
	bootsplash_index = -1
	if bootsplash_paths.size() > 0:
		await get_tree().create_timer(0.5).timeout
		load_next_bootsplash()


func load_next_bootsplash() -> void:
	bootsplash_index += 1
	print("Loading BootSplash #%d" % bootsplash_index)
	
	if (bootsplash_index >= bootsplash_paths.size() or 
	SettingsManager.get_value("skip_bootsplash", "SceneManager")):
		# bootsplashes are done, load main menu
		# TODO: switch loading_screen to boot_screen and preload main & assets
		load_scene(main_menu_scene_path)
	else:
		load_scene(bootsplash_paths[bootsplash_index])


func load_scene(incoming_scene_path: String, transition: String = "color_fade", options: Dictionary = { "color": Color("#242424") }) -> void:
	#print("1. scene_manager load_scene")
	var _loading_screen = loading_screen.instantiate()
	
	get_tree().get_root().add_child(_loading_screen)
	
	# have loading_screen load the new scene
	_loading_screen.scene_loaded.connect(on_scene_loaded)
	_loading_screen.midpoint_reached.connect(on_midpoint_reached)
	_loading_screen.transitions_finished.connect(on_transitions_finished)
	_loading_screen.load_scene(current_scene, incoming_scene_path, transitions[transition], options)


func on_scene_loaded(incoming_scene: Node) -> void:
	#print("3.5. scene_manager on_scene_loaded")
	current_scene = incoming_scene
	
	# keep main_menu bottom of stack
	if incoming_scene.scene_file_path == main_menu_scene_path:
		clear_scene_stack()
	
	# make sure incoming_scene and last scene aren't the same
	if (
		_scene_stack
		and incoming_scene.scene_file_path == _scene_stack.back()
	):
		_scene_stack.pop_back()
	
	_scene_stack.push_back(incoming_scene.scene_file_path)
	
	# TODO: Figure out when to trim the stack, clear loops?


func on_midpoint_reached() -> void:
	#print("4.1. scene_manager on_midpoint_reached")
	add_child(current_scene)


func on_transitions_finished() -> void:
	#print("7. scene_manager on_transitions_finished")
	if current_scene is BootSplash:
		current_scene.display_logo()


func has_previous_scene() -> bool:
	return _scene_stack.size() > 1


func load_previous_scene(transition: String) -> void:
	if has_previous_scene():
		# remove current scene
		_scene_stack.pop_back()
		# go to previous scene
		load_scene(_scene_stack.pop_back(), transition)


func clear_scene_stack() -> void:
	_scene_stack = []
