extends CharacterBody2D

signal hp_changed(new_hp)
signal died

const DAMAGE_INDICATOR = preload("res://UI/damage_indicator.tscn")

enum entity_types {PLAYER, ENEMY}
var entity_type = entity_types.ENEMY

const GRAVITY = 2000
var is_atacando = false
var cooldown_ataque = 0
var _jump_count = 0
var is_jumping = false
@export var maximum_jumps = 5
var jump_strength = 800.0
var multi_jump_strength = 500
var dead = false
var speed = 400
var is_moving_left = true

# Estatísticas de combate
var attack_duration = 0
var receives_knockback = true
@export var damage = 0
var knockack_modifier = 3
@export var defense = 2
var max_health = 100:
	set(value):
		max_health = value
		$EntityHealthBar.max_value = value
var current_health = max_health : 
	set (value):
		current_health = clamp(value, 0, max_health)
		if current_health == max_health:
			$EntityHealthBar.visible = false
		else:
			if entity_type == entity_types.ENEMY:
				$EntityHealthBar.visible = true
			
		$EntityHealthBar.value = current_health	
		emit_signal("hp_changed", current_health)
		if current_health == 0:
			emit_signal("died")
	get:
		return current_health
		
# Animações
var animation_death_duration = 1.4

@onready var sprite = $AnimatedSprite2D
@onready var collShape = $CollisionShape2D
@onready var animPlayer = $AnimationPlayer


func _physics_process(delta):
	if Input.is_action_just_pressed("stats"):
		print("Os atributos de " + name + "são: ")
		print("HP Máximo: " + str(max_health))
		print("HP atual: " + str(current_health))
		print("Defesa: " + str(defense))
		print("Número de saltos: " + str(maximum_jumps))
	
	
func move():
	move_and_slide()
	

func die():
	queue_free()


func receive_damage(base_damage):
	var actual_damage = base_damage
	actual_damage -= defense
	actual_damage = clamp(actual_damage, 0, abs(actual_damage))
	current_health -= actual_damage
	spawn_damage_indicator(actual_damage)
	return actual_damage
	
	
func spawn_effect(EFFECT: PackedScene, effect_position: Vector2 = global_position):
	if EFFECT:
		var effect = EFFECT.instantiate()
		get_tree().current_scene.add_child(effect)
		effect.global_position = effect_position
		return effect
		
	
func spawn_damage_indicator(damage):
	var indicator = spawn_effect(DAMAGE_INDICATOR)
	if indicator:
		indicator.label.text = str(damage)
	
func _on_hurtbox_area_entered(hitbox):
		# Detectando o tipo de entidade que recebeu o hit
	if entity_type == entity_types.ENEMY:
		$AnimationPlayer.play("attack")
		is_atacando = true
	else:
		print(entity_type)
		
	if hitbox.is_in_group("Projectile"):
		hitbox.destroy()
	var damage = receive_damage(hitbox.damage)
	
	
func _on_died():
	self.dead = true
	$AnimationPlayer.play("death")
	print(name + " morreu")
	await get_tree().create_timer(animation_death_duration).timeout
	die()


func detect_edge():
	if not $Sprite2D/RayCast2D.is_colliding() and is_on_floor():
		return false
	return true
	

func detect_player():
	if $Sprite2D/EntityDetector.is_colliding():
		return true
	return false
