extends Node

var signal_list: Dictionary = {} # String -> Signal


func get_signal(signal_name: String) -> Signal:
	if signal_list.has(signal_name):
		return signal_list[signal_name]
	else:
		# return empty signal. similar to null, but signal isn't nullable
		# check for null by using:
		# if signal_name.is_null():
		return Signal()


func register_signal(signal_name: String, _signal: Signal, _surpress_warning: bool = false) -> Signal:
	if not signal_list.has(signal_name):
		signal_list[signal_name] = _signal
	else:
		if not _surpress_warning:
			push_warning("%s already registered" % signal_name)
	
	return signal_list[signal_name]


func connect_to_signal(signal_name: String, callable: Callable) -> void:
	if signal_list.has(signal_name):
		if not signal_list[signal_name].is_connected(callable):
			signal_list[signal_name].connect(callable)
		else:
			push_warning("%s is already connected to %s" % [callable, signal_name])
	else:
		push_error("%s not found" % signal_name)
