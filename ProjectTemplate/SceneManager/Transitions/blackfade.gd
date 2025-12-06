extends Transition


func _init() -> void:
	transition_name = "black_fade"
	
	fade_in_time = 0.7
	fade_out_time = 0.7


## Call transitioned_in() when transition is complete
func start(loading_screen: Node, _outgoing_scene: Node, _options: Dictionary = {}) -> void:
	#print("3. transition start")
	var tween = loading_screen.get_tree().create_tween()
	tween.tween_property(loading_screen, "modulate", Color("000000ff"), fade_in_time).from(Color("00000000"))
	
	await tween.finished
	transitioned_in.emit()


## Call transitioned_out() when transition is complete
func finish(loading_screen: Node, _outgoing_scene: Node, _incoming_scene: Node, _options: Dictionary = {}) -> void:
	#print("5. transition finish")
	if _outgoing_scene:
		_outgoing_scene.queue_free()
	
	var tween = loading_screen.get_tree().create_tween()
	tween.tween_property(loading_screen, "modulate", Color("00000000"), fade_out_time)
	
	await tween.finished
	transitioned_out.emit()
