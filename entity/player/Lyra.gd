extends "res://entity/EntityBase.gd"

# Modificadores de atributos
var shield_health        = 0.0
var health_regen         = 0.0
var speed_modifier       = 0.0
var speed_modifier_perc  = 1.0
var attack_modifier      = 0.0
var attack_modifier_perc = 1.0

# Estados
var is_running = false
var is_casting = false

@export var FIREBALL: PackedScene = preload("res://Spells/Fireball.tscn")
@onready var castTimer = $CastTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	#hide()
	knockack_modifier = 20
	entity_type = entity_types.PLAYER
	max_health = 500
	current_health = max_health
	$CanvasGroup/HUD/TextureProgressBar.max_value = max_health
	$CanvasGroup/HUD/TextureProgressBar.value = current_health
	$Sprite2D/Hitbox.damage = damage


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not dead:
		_movementControl(delta)
		_attack(delta)
		if Input.is_action_just_pressed("reset"):
			get_tree().reload_current_scene()
		


func _movementControl(delta):
	if Input.is_action_just_pressed("run"):
		speed_modifier_perc += 0.5
		is_running = true
		
	if Input.is_action_just_released("run"):
		speed_modifier_perc -= 0.5
		is_running = false
		
	var _horizontal_direction = (
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	)
	
	velocity.x = (_horizontal_direction * speed + speed_modifier) * speed_modifier_perc
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
	
	if _is_idling and not is_atacando and not is_casting:
		#print("Idle")
		$AnimationPlayer.play("idle")
	
	if sign($Sprite2D.scale.x) != sign(_horizontal_direction) and _horizontal_direction != 0:
		$Sprite2D.scale.x *= -1
		
	if _is_running:
		if not is_atacando and not is_casting:
			#print("Walk")
			if is_running:
				$AnimationPlayer.play("run")
			else:
				$AnimationPlayer.play("walk")
	
	if _is_falling and not is_atacando and not is_casting:
		#print("fall")
		$AnimationPlayer.play("fall")
	
	move()
	


func _attack(delta):
	if is_atacando:
		cooldown_ataque += delta
		if cooldown_ataque > 0.3:
			$AnimationPlayer.play("idle")
			speed = 400			
			is_atacando = false
			
	if Input.is_action_just_pressed("attack"):
		print("attack")
		
		if not is_atacando:
			$AnimationPlayer.play("attack")
			speed = 100				
			cooldown_ataque = 0
			is_atacando = true
			
	if Input.is_action_just_pressed("cast"):
		print("cast")
		
		if not is_casting and castTimer.is_stopped() and FIREBALL:
			if FIREBALL:
				var fireball = FIREBALL.instantiate()
				get_tree().current_scene.add_child(fireball)
				fireball.global_position = self.global_position
				
				var fireball_rotation = self.global_position.direction_to(get_global_mouse_position()).angle()
				fireball.rotation = fireball_rotation
				$AnimationPlayer.play("cast")
				castTimer.start()
					
				speed = 100				
				cooldown_ataque = 0
				is_atacando = true


func _on_hp_changed(new_hp):
	$CanvasGroup/HUD/TextureProgressBar.value = new_hp
