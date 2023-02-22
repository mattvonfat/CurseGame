extends StaticBody2D

signal player_entered(room_number, damaged, tile)

var room_number

func set_room_number(new_room_number):
	room_number = new_room_number

func get_room_number():
	return room_number

func hide_tile():
	pass

func show_tile():
	pass

func get_collider_type():
	return "WALL"
