extends KinematicBody2D

signal enemy_died(enemy_reference)

export(SpriteFrames) var idle_animation
export(SpriteFrames) var walk_animation
export(SpriteFrames) var attack_animation

enum { IDLE, WALKING, ATTACKING }

onready var miss_label = $Label

var max_health
var current_health

var enemy_type

var room_number
var room_active = false

var move_speed = 30.0
var attack_range = 30

var player
var status

var attack_damage = 10
var attack_speed = 2
var can_attack = true

func _ready():
	max_health = 50
	current_health = 50
	enemy_type = "STANDARD"
	$AnimatedSprite.set_sprite_frames(idle_animation)
	status = IDLE
	miss_label.hide()

func set_player(player_reference):
	player = player_reference

func _physics_process(delta):
	# only want to do stuff if the player is in the room
	if room_active == true:
		var player_position = player.position
		
		look_at(player_position)
		
		if position.distance_to(player_position) <= attack_range:
			if status != ATTACKING:
				status = ATTACKING
				$AnimatedSprite.set_sprite_frames(attack_animation)
				$AnimatedSprite.play()
			if can_attack:
				player.do_damage(attack_damage * GameManager.get_attack_multiplier())
				can_attack = false
				$AttackTimer.start()
			
		else:
			if status != WALKING:
				status = WALKING
				$AnimatedSprite.set_sprite_frames(walk_animation)
				$AnimatedSprite.play()
			var velocity = position.direction_to(player_position) * move_speed
			move_and_slide(velocity)

func set_room_number(room_id):
	room_number = room_id

func get_room_number():
	return room_number

func do_damage(damage_amount):
	if GameManager.shot_missed() == false:
		current_health -= damage_amount
		if current_health <= 0:
			queue_free()
			emit_signal("enemy_died", self)
	else:
		miss_label.show()
		$MissTimer.start()

func get_collider_type():
	return "ENEMY"

func get_enemy_type():
	return enemy_type

func hide_enemy():
	room_active = false
	status = IDLE
	$AnimatedSprite.set_sprite_frames(idle_animation)
	hide()

func show_enemy():
	room_active = true
	show()


func _on_AttackTimer_timeout():
	can_attack = true
	


func _on_MissTimer_timeout():
	miss_label.hide()
