extends KinematicBody2D

signal health_update(new_health)

export(SpriteFrames) var idle
export(SpriteFrames) var walk


onready var shot_timer = $ShotTimer

const DEFAULT_SHOT_TIME : float = 0.4
const DEFAULT_MAX_HEALTH : int = 100
const DEFAULT_MOVE_SPEED : float = 200.0

var max_health : int
var current_health : int

var move_speed : float

var can_shoot : bool = true

var walking = false

func _ready():
	shot_timer.set_wait_time(DEFAULT_SHOT_TIME)
	max_health = DEFAULT_MAX_HEALTH
	current_health = max_health
	move_speed = DEFAULT_MOVE_SPEED
	$AnimatedSprite.set_sprite_frames(idle)

func _physics_process(_delta):
	var velocity = Vector2()
	
	if Input.is_action_pressed("move_up"):
		velocity.y += -1
	
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	
	if Input.is_action_pressed("move_left"):
		velocity.x += -1
	
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	
	if Input.is_action_pressed("shoot_gun"):
		if can_shoot == true:
			can_shoot = false
			shot_timer.start()
			GameManager.fire_bullet($Position2D.get_global_position(), $Position2D.get_global_position().direction_to(get_global_mouse_position()))
			$GunSound.play()
	
	look_at(get_global_mouse_position())
	
	if (velocity != Vector2(0,0)):
		if walking == false:
			walking = true
			$AnimatedSprite.set_sprite_frames(walk)
			$AnimatedSprite.play()
	else:
		$AnimatedSprite.set_sprite_frames(idle)
		walking = false
	
	move_and_slide(velocity.normalized() * move_speed)

func reset_player():
	current_health = max_health
	can_shoot = true


func do_damage(damage_amount):
	current_health -= damage_amount
	emit_signal("health_update", current_health)
	if current_health <= 0:
		GameManager.player_died()

func _on_Area2D_area_entered(_area):
	pass


func _on_ShotTimer_timeout():
	can_shoot = true


func get_max_health():
	return max_health

func add_health_degen():
	$DegenTimer.start()

func _on_DegenTimer_timeout():
	current_health -= 1
	emit_signal("health_update", current_health)

func reduce_speed():
	move_speed = 100.0

func slow_shooting():
	shot_timer.set_wait_time(0.9)

func get_collider_type():
	return "ENEMY"
