extends Node2D

var bg_color: Color = Color("ffffffcc")
var color: Color = Color.BLACK
var radius: float = 100


func _ready():
	set_process(true)


func _process(_delta):
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius*1.1, bg_color)
	draw_circle(Vector2.ZERO, radius, color)
