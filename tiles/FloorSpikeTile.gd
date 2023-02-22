extends StaticBody2D

signal player_entered(room_number, damaged, tile)

onready var room_timer : Timer = $Timer

const SPIKE_UP_DELAY = 1.0
const SPIKE_DOWN_DELAY = 2.0
const SPIKE_ANIMATION_DELAY = 0.1

var room_number

var spike_status

var tile_hidden : bool
var tile_frame

var player_in = false
var player

func _ready():
	tile_frame = 1
	tile_hidden = false
	room_timer.set_wait_time(SPIKE_UP_DELAY)
	spike_status = "down"
	room_timer.start()


func _on_Timer_timeout():
	match spike_status:
		"down":
			tile_frame = 2
			if tile_hidden == false:
				$AnimatedSprite.set_frame(tile_frame)
			room_timer.set_wait_time(SPIKE_ANIMATION_DELAY)
			room_timer.start()
			spike_status = "moving_up"
		
		"moving_up":
			tile_frame += 1
			if tile_hidden == false:
				$AnimatedSprite.set_frame(tile_frame)
			if tile_frame == 4:
				spike_status = "up"
				room_timer.set_wait_time(SPIKE_DOWN_DELAY)
				room_timer.start()
				if player_in:
					player.do_damage(5)
			else:
				room_timer.set_wait_time(SPIKE_ANIMATION_DELAY)
				room_timer.start()
		
		"up":
			tile_frame = 3
			if tile_hidden == false:
				$AnimatedSprite.set_frame(tile_frame)
			room_timer.set_wait_time(SPIKE_ANIMATION_DELAY)
			room_timer.start()
			spike_status = "moving_down"
		
		"moving_down":
			tile_frame -= 1
			if tile_hidden == false:
				$AnimatedSprite.set_frame(tile_frame)
			if tile_frame == 1:
				spike_status = "down"
				room_timer.set_wait_time(SPIKE_UP_DELAY)
				room_timer.start()
			else:
				room_timer.set_wait_time(SPIKE_ANIMATION_DELAY)
				room_timer.start()

func hide_tile():
	tile_hidden = true
	$AnimatedSprite.set_frame(0)

func show_tile():
	tile_hidden = false
	$AnimatedSprite.set_frame(tile_frame)

func set_room_number(new_room_number):
	room_number = new_room_number

func get_room_number():
	return room_number

func _on_Area2D_area_entered(_area):
	var is_damaged = false
	if spike_status == "up":
		is_damaged = true
	emit_signal("player_entered", room_number, is_damaged, self)
	player_in = true

func set_player(p):
	player = p

func _on_Area2D_area_exited(_area):
	player_in = false
