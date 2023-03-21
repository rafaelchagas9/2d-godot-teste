extends "res://entity/EntityBase.gd"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	animation_death_duration = 1.2
	entity_type = entity_types.ENEMY
	speed = 80
	velocity.x = speed
	damage = 10
	max_health = 100
	$Sprite2D/Hitbox.damage = damage	
	
func _physics_process(delta):
	if not dead:
		var is_on_edge: bool = detect_edge()
		process_movement(delta, !is_on_edge)


func process_movement(delta, is_on_edge):
	# Add the gravity.
	
	if is_moving_left:
		$Sprite2D.scale.x = 1
	else:
		$Sprite2D.scale.x = -1
		
	if not is_on_floor():
		velocity.y += gravity * delta
		
	var _is_falling = velocity.y > 5.0 and not is_on_floor()
	var _is_running = is_on_floor() and not is_zero_approx(velocity.x)
	var _is_idling = is_on_floor() and is_zero_approx(velocity.x)
	
	if _is_idling and not is_atacando:
		$AnimationPlayer.play("idle")
	
	if velocity.x != 0 and not is_atacando:
		$AnimationPlayer.play("walk")
	
	if is_on_edge:
		is_moving_left = !is_moving_left
		if is_moving_left:
			$Sprite2D.scale.x = 1
			velocity.x = speed
		else:
			$Sprite2D.scale.x = -1
			velocity.x = -speed
			
	if velocity.x == 0:
		if is_moving_left:
			$Sprite2D.scale.x = 1
			velocity.x = speed
		else:
			$Sprite2D.scale.x = -1
			velocity.x = -speed
		
	move()
