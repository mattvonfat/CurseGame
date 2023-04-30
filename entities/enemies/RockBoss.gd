extends KinematicBody2D

signal enemy_died(enemy_reference)

export(SpriteFrames) var idle_animation
export(SpriteFrames) var walk_animation
export(SpriteFrames) var attack_animation

enum { IDLE, WALKING, ATTACKING }

var max_health
var current_health

var enemy_type

var room_number
var room_active = false

var move_speed = 30.0
var attack_range_melee = 40

var player
var status

var attack_damage_melee = 30
var attack_damage_throw = 10
var attack_speed_melee = 2
var attack_speed_throw = 5
var can_attack_melee = true
var can_attack_throw = true

var throwing = false

func _ready():
	max_health = 200
	current_health = 200
	enemy_type = "BOSS"
	$AnimatedSprite.set_sprite_frames(idle_animation)
	status = IDLE

func set_player(player_reference):
	player = player_reference

func _physics_process(delta):
	# only want to do stuff if the player is in the room
	if room_active == true:
		var player_position = player.position
		
		look_at(player_position)
		
		if position.distance_to(player_position) <= attack_range_melee:
			if status != ATTACKING:
				status = ATTACKING
				$AnimatedSprite.set_sprite_frames(attack_animation)
				$AnimatedSprite.play()
			if can_attack_melee:
				player.do_damage(attack_damage_melee)
				can_attack_melee = false
				$MeleeAttackTimer.start()
			
		else:
			if can_attack_throw:
				status = ATTACKING
				can_attack_throw = false
				$ThrowAttackTimer.set_wait_time(0.6)
				$ThrowAttackTimer.start()
				throwing = true
				$AnimatedSprite.set_sprite_frames(attack_animation)
				$AnimatedSprite.play()
			else:
				if throwing != true:
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
	current_health -= damage_amount
	if current_health <= 0:
		queue_free()
		emit_signal("enemy_died", self)

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


func _on_MeleeAttackTimer_timeout():
	can_attack_melee = true


func _on_ThrowAttackTimer_timeout():
	if throwing == true:
		throwing = false
		$ThrowAttackTimer.set_wait_time(attack_speed_throw)
		$ThrowAttackTimer.start()
		GameManager.throw_rock($RockPos.get_global_position(), $RockPos.get_global_position().direction_to(player.get_global_position()))
	else:
		can_attack_throw = true
