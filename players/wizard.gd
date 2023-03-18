extends CharacterBody2D

@export var max_speed = 400.0
@export var acceleration = 100.0
var jump_strength = 800.0
@export var jump_base = 100
@export var jump_limit = 1
const GRAVITY = 2000
var screen_size # Size of the game window.
var is_atacando = false
var cooldown_ataque = 0
var _jump_count = 0
var air_time = 0
var terminal_velocity = 550
var is_jumping = false
var maximum_jumps = 5
var multi_jump_strength = 500


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	#hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_movementControl(delta)
	_attack(delta)
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


func _movementControl(delta):
	var _horizontal_direction = (
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	)
	
	velocity.x = _horizontal_direction * max_speed
	velocity.y += GRAVITY * delta
	
	var _is_falling = velocity.y > 5.0 and not is_on_floor()
	var _is_running = is_on_floor() and not is_zero_approx(velocity.x)
	var _is_multi_jumping = Input.is_action_just_pressed("jump") and _is_falling
	var _is_jumping = Input.is_action_just_pressed("jump") and is_on_floor()
	var _is_jump_cancelled = Input.is_action_just_released("jump") and velocity.y < 0.0
	var _is_idling = is_on_floor() and is_zero_approx(velocity.x) and not _is_jumping	
	
	if _is_jumping:
		velocity.y = -jump_strength
		if not is_atacando:
			$AnimatedSprite2D.play("jump")	
		_jump_count += 1
	elif _is_multi_jumping:
		_jump_count += 1
		if not is_atacando:
			$AnimatedSprite2D.play("jump")	
		if _jump_count <= maximum_jumps:
			velocity.y = -jump_strength
	elif _is_jump_cancelled:
		velocity.y = 0.0
	elif _is_idling or _is_running:
		_jump_count = 0
	
	if _is_idling and not is_atacando:
		print("Idle")
		$AnimatedSprite2D.play("idle")
	
	if _horizontal_direction > 0:
		$AnimatedSprite2D.flip_h = false
	elif _horizontal_direction < 0:
		$AnimatedSprite2D.flip_h = true
	if _is_running:
		if not is_atacando:
			print("run")
			$AnimatedSprite2D.play("run")		
	
	if _is_falling and not is_atacando:
		print("fall")
		$AnimatedSprite2D.play("fall")
	
	move_and_slide()	
	


func _attack(delta):
		
	if is_atacando:
		cooldown_ataque += delta
		if cooldown_ataque > 1:
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
