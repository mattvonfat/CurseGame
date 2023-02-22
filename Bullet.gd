extends KinematicBody2D

var bullet_speed = 200
var bullet_damage = 15

var bullet_direction : Vector2

func initiate(direction : Vector2):
	bullet_direction = direction

func _physics_process(delta):
	var collision
	
	if bullet_direction:
		collision = move_and_collide(bullet_direction * bullet_speed * delta)
		
	if collision:
		var collider = collision.get_collider()
		var collider_type = collider.get_collider_type()
		
		match collider_type:
			"WALL":
				queue_free()
			
			"ENEMY":
				collider.do_damage(bullet_damage)
				queue_free()
