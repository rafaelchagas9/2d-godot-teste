extends "res://overlap/hitbox.gd"

@export var SPEED: int = 300
var projectile_dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	damage = 50
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not projectile_dead:
		var direction = Vector2.RIGHT.rotated(rotation)
		global_position += SPEED * direction * delta


func destroy():
	$DestroyTimer.start()
	projectile_dead = true
	print("start")
	$AnimationPlayer.play("explode")

func _on_area_entered(area):
	destroy()

func _on_body_entered(body):
	destroy()
		

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_destroy_timer_timeout():
	queue_free()
