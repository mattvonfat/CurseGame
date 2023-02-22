extends Area2D

signal picked_up(treasure_reference)

var room_number

func set_room_number(room_id):
	room_number = room_id

func get_room_number():
	return room_number

func hide_pickup():
	hide()

func show_pickup():
	show()

func _on_Treasure1_area_entered(area):
	emit_signal("picked_up", self)
	print("in")

func set_treasure(treasure_number):
	$Sprite.set_texture(GameData.treasure_list[treasure_number]["image"])
