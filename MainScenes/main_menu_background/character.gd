extends Label

const DIRECTIONS: Array = [
	Vector2i.UP,
	Vector2i.UP + Vector2i.RIGHT,
	Vector2i.RIGHT,
	Vector2i.DOWN + Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.DOWN + Vector2i.LEFT,
	Vector2i.LEFT,
	Vector2i.UP + Vector2i.LEFT,
	]

@onready var move_timer: Timer = $Timer

@export var move_time: float
# TODO: Decide to add wait time and change direction

var direction: Vector2i


func _ready() -> void:
	move_timer.timeout.connect(_move)
	_pick_direction()
	
	move_timer.start(move_time)


func _pick_direction() -> void:
	direction = DIRECTIONS[randi() % DIRECTIONS.size()]


func _move() -> void:
	self.position += (direction * 24) as Vector2
	
	move_timer.start(move_time)
