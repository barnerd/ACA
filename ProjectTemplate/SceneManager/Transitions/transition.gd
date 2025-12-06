class_name Transition

signal transitioned_in
signal transitioned_out

var transition_name: String = "empty"
var fade_in_time: float = 1.0
var fade_out_time: float = 1.0


## Call transitioned_in() when transition is complete
func _start(_loading_screen: Node, _outgoing_scene: Node = null, _options: Dictionary = {}) -> void:
	transitioned_in.emit()


## Call transitioned_out() when transition is complete
func _finish(_loading_screen: Node, _outgoing_scene: Node, _incoming_scene: Node, _options: Dictionary = {}) -> void:
	if _outgoing_scene:
		_outgoing_scene.queue_free()
	
	transitioned_out.emit()
