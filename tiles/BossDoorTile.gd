extends StaticBody2D

signal player_entered(room_number, damaged, tile)

export(SpriteFrames) var door_frames
export(SpriteFrames) var door_frames_side

enum { NORTH=0, SOUTH=1, EAST=2, WEST=3 }

var room_number
var room_direction

func set_room_number(new_room_number):
	room_number = new_room_number

func set_room_direction(direction):
	room_direction = direction
	if room_direction == NORTH or room_direction == SOUTH:
		$AnimatedSprite.set_sprite_frames(door_frames)
		$AnimatedSprite.set_frame(0)
	else:
		$AnimatedSprite.set_sprite_frames(door_frames_side)
		$AnimatedSprite.set_frame(0)

func get_room_number():
	return room_number

func hide_tile():
	pass

func show_tile():
	pass

func get_collider_type():
	return "WALL"

func open_door():
	$CollisionShape2D.disabled = true
	$AnimatedSprite.play()
	$AudioStreamPlayer.play()


func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.stop()
	$AnimatedSprite.set_frame(6)
