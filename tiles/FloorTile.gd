extends StaticBody2D

signal player_entered(room_number, damaged)

var room_number

var tile_hidden : bool
var tile_frame

var breaking = false

var safe = false

var player_in = false
var player

var room_type = "NORMAL"

func _ready():
	tile_frame = 1
	tile_hidden = false

func start_break():
	if safe == false and breaking == false:
		tile_frame += 1
		breaking = true
		$Timer.set_wait_time(3)
		$Timer.start()
		if tile_hidden == false:
			$AnimatedSprite.set_frame(tile_frame)

func _on_Timer_timeout():
	if tile_frame < 3:
		tile_frame += 1
		if tile_hidden == false:
			$AnimatedSprite.set_frame(tile_frame)
	else:
		tile_frame += 1
		if tile_hidden == false:
			$AnimatedSprite.set_frame(tile_frame)
		$Timer.stop()
		$CollisionShape2D.disabled = false
		if player_in == true:
			player.do_damage(1000)

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

func set_player(p):
	player = p

func _on_Area2D_area_entered(area):
	emit_signal("player_entered", room_number, false, self)
	player_in = true

func set_room_type(room_t):
	room_type = room_t

func get_room_type():
	return room_type


func _on_Area2D_area_exited(_area):
	player_in = false

func set_as_safe():
	safe = true
