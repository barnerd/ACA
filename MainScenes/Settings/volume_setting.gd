extends Container

@export var bus: SoundManager.SoundChannel
@export var label_text: String

@onready var label = $Label
@onready var slider = $HSlider
@onready var value_label = $Value


func _ready() -> void:
	var volume: float = 0
	
	volume = SoundManager.get_volume(bus)
	
	label.text = label_text
	slider.value = volume * 100.0
	value_label.text = _volume_string(volume * 100.0)


func _on_h_slider_value_changed(value: float) -> void:
	SoundManager.set_volume(bus, value / 100.0)
	
	value_label.text = _volume_string(value)


func _volume_string(_volume: float) -> String:
	return str(roundi(_volume))
