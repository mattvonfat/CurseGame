extends Node2D

onready var temple_select_button = $CanvasLayer/TextureRect/VBoxContainer/CenterContainer3/HBoxContainer2/TempleSelect
onready var level_buttons = [
	$CanvasLayer/TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Level1,
	$CanvasLayer/TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Level2,
	$CanvasLayer/TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Level3,
	$CanvasLayer/TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Level4
]
onready var curse_name_box = $CanvasLayer/TextureRect/VBoxContainer/CenterContainer2/TextureRect/MarginContainer/VBoxContainer/CurseName
onready var level_description = $CanvasLayer/TextureRect/VBoxContainer/CenterContainer2/TextureRect/MarginContainer/VBoxContainer/CurseDescription

onready var level_names = [
	$CanvasLayer/TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Level1/MarginContainer/VBoxContainer/LevelName,
	$CanvasLayer/TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Level2/MarginContainer/VBoxContainer/LevelName,
	$CanvasLayer/TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Level3/MarginContainer/VBoxContainer/LevelName,
	$CanvasLayer/TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Level4/MarginContainer/VBoxContainer/LevelName
	
]

onready var level_treasure_icons = [
	$CanvasLayer/TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Level1/MarginContainer/VBoxContainer/CenterContainer/TextureRect,
	$CanvasLayer/TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Level2/MarginContainer/VBoxContainer/CenterContainer/TextureRect,
	$CanvasLayer/TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Level3/MarginContainer/VBoxContainer/CenterContainer/TextureRect,
	$CanvasLayer/TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Level4/MarginContainer/VBoxContainer/CenterContainer/TextureRect
]

onready var disabled_cover = [
	$CanvasLayer/TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Level1/TextureRect,
	$CanvasLayer/TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Level2/TextureRect,
	$CanvasLayer/TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Level3/TextureRect,
	$CanvasLayer/TextureRect/VBoxContainer/CenterContainer/HBoxContainer/Level4/TextureRect
]

var level_data
var selected_level : int


func update_level_menu(_level_data):
	level_data = _level_data
	for level in level_data:
		var level_index = level["id"]-1
		level_names[level_index].set_text(level["name"])
		disabled_cover[level_index].hide()
		level_treasure_icons[level_index].set_texture(GameData.get_treasure_icon(level["treasure"]))
		
		if level["completed"] == true:
			level_buttons[level_index].disabled = true
			disabled_cover[level_index].show()

func _on_LevelButton_pressed(level_number):
	temple_select_button.disabled = false
	selected_level = level_number
	curse_name_box.set_text("Inflicts %s" % GameData.get_curse_name(level_data[level_number-1]["curse"]))
	level_description.set_text(GameData.get_curse_description(level_data[level_number-1]["curse"]))

func _on_TempleSelect_pressed():
	GameManager.load_level(selected_level)



func _on_button_mouse_entered():
	$AudioStreamPlayer.play()
