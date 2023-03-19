extends Node2D

@export var SPEED = 30
@export var FRICTION = 15
var SHIFT_DIRECTION = Vector2.ZERO

@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	SHIFT_DIRECTION = Vector2(randi_range(-1, 1), randi_range(-1, 1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += SPEED * SHIFT_DIRECTION * delta
	SPEED = max(SPEED - FRICTION * delta, 0)
