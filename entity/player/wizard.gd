extends "res://entity/EntityBase.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	#hide()
	knockack_modifier = 20
	entity_type = entity_types.PLAYER
	damage = 20
	$Sprite2D/Hitbox.damage = damage


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not dead:
		_movementControl(delta)
		_attack(delta)
		if Input.is_action_just_pressed("reset"):
			get_tree().reload_current_scene()
		


func _movementControl(delta):
	var _horizontal_direction = (
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	)
	
	velocity.x = _horizontal_direction * speed
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
			$AnimationPlayer.play("jump")	
		_jump_count += 1
	elif _is_multi_jumping:
		_jump_count += 1
		if not is_atacando:
			$AnimationPlayer.play("jump")	
		if _jump_count <= maximum_jumps:
			velocity.y = -multi_jump_strength
	elif _is_jump_cancelled:
		velocity.y = 0.0
	elif _is_idling or _is_running:
		_jump_count = 0
	
	if _is_idling and not is_atacando:
		#print("Idle")
		$AnimationPlayer.play("idle")
	
	if sign($Sprite2D.scale.x) != sign(_horizontal_direction) and _horizontal_direction != 0:
		$Sprite2D.scale.x *= -1
		
	if _is_running:
		if not is_atacando:
			#print("Walk")
			$AnimationPlayer.play("walk")		
	
	if _is_falling and not is_atacando:
		#print("fall")
		$AnimationPlayer.play("fall")
	
	move()
	


func _attack(delta):
		
	if is_atacando:
		cooldown_ataque += delta
		if cooldown_ataque > 1:
			$AnimationPlayer.play("idle")
			speed = 400			
			is_atacando = false
			
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print("attack")
		
		if not is_atacando:
			$AnimationPlayer.play("attack")
			speed = 100				
			cooldown_ataque = 0
			is_atacando = true

