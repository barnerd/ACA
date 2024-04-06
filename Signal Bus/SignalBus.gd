extends Node

var signal_list: Dictionary = {} # String -> Signal


func register_signal(_name: String, _signal: Signal):
	if not signal_list.has(_name):
		signal_list[_name] = _signal


func connect_signal(_name: String, _callable: Callable):
	if not signal_list[_name].is_connected(_callable):
		signal_list[_name].connect(_callable)


# TODO: write unregister func
func unregister_signal(_name: String):
	# disconnect listeners first
	pass
