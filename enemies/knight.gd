extends CharacterBody2D

@export var max_speed = 1000.0
@export var acceleration = 100.0
var jump_strength = 800.0
@export var jump_base = 100
@export var jump_limit = 1
const GRAVITY = 2000
var screen_size # Size of the game window.
var is_atacando = false
var cooldown_ataque = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	#hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_movementControl(delta)
	_attack(delta)


func _movementControl(delta):
	velocity.y += GRAVITY * delta
	move_and_slide()
	pass
	


func _attack(delta):
		
	if is_atacando:
		cooldown_ataque += delta
		if cooldown_ataque >= 2:
			print_debug("Parando")
			$AnimatedSprite2D.play("idle")
			max_speed = 400			
			is_atacando = false
			
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print_debug("attack")
		
		if not is_atacando:
			$AnimatedSprite2D.play("attack")
			max_speed = 100				
			cooldown_ataque = 0
			is_atacando = true
