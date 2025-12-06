extends Transition


func _init() -> void:
	transition_name = "color_fade"
	
	fade_in_time = 0.7
	fade_out_time = 0.7


## Call transitioned_in() when transition is complete
func start(loading_screen: Node, _outgoing_scene: Node, _options: Dictionary = {}) -> void:
	#print("3. color: transition start")
	
	if _options.has("color"):
		loading_screen.modulate = _options["color"]
	
	var tween = loading_screen.get_tree().create_tween()
	tween.tween_property(loading_screen, "modulate:a", 1.0, fade_in_time).from(0.0)

	await tween.finished
	transitioned_in.emit()


## Call transitioned_out() when transition is complete
func finish(loading_screen: Node, _outgoing_scene: Node, _incoming_scene: Node, _options: Dictionary = {}) -> void:
	#print("5. color: transition finish")
	if _outgoing_scene:
		_outgoing_scene.queue_free()
	
	var tween = loading_screen.get_tree().create_tween()
	tween.tween_property(loading_screen, "modulate:a", 0.0, fade_out_time)
	
	await tween.finished
	transitioned_out.emit()
