extends StaticBody2D

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var jump_strength = 1
@export var jump_base = 1000
@export var player_gravity = 10
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
	var velocity = Vector2.ZERO # The player's movement vector.
	
	# 0 = Movimento horizontal
	# 1 = Movimento vertical para cima
	# 2 = Movimento vertical para baixo
	var direcaoMovimento = -1
	
	if Input.is_action_pressed("move_right"):
		scale.x = scale.y * 1
		velocity.x += 1
		direcaoMovimento = 0
	if Input.is_action_pressed("move_left"):
		scale.x = scale.y * -1		
		velocity.x -= 1
		direcaoMovimento = 0		
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		direcaoMovimento = 2
	if Input.is_action_pressed("move_up"):
		velocity.y -= jump_base
		direcaoMovimento = 1

	if velocity.length() > 0:
		if direcaoMovimento == 1:
			velocity = velocity.normalized() * jump_base * jump_strength			
		else:
			velocity = velocity.normalized() * speed
		if not is_atacando:
			$AnimatedSprite2D.play("walk")
	else:
		if not is_atacando:		
			$AnimatedSprite2D.play("idle")			
	
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	


func _attack(delta):
		
	if is_atacando:
		cooldown_ataque += delta
		if cooldown_ataque > 1:
			print_debug("Parando")
			$AnimatedSprite2D.play("idle")					
			is_atacando = false
			
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print_debug("attack")
		
		if not is_atacando:
			$AnimatedSprite2D.play("attack")		
			cooldown_ataque = 0
			is_atacando = true

