extends Control

onready var name_text = $CenterContainer/VBoxContainer/LineEdit
onready var thing_text = $CenterContainer/VBoxContainer/LineEdit2
onready var button = $CenterContainer/VBoxContainer/Button

var name_entered = false
var thing_entered = false

func _ready():
	button.disabled = true

func _on_Button_pressed():
	var user_name = name_text.get_text()
	var user_thing = thing_text.get_text()
	GameManager.go_to_story(user_name, user_thing)

func _on_LineEdit_text_changed(new_text):
	if new_text == "":
		name_entered = false
		button.disabled = true
	else:
		name_entered = true
		if thing_entered == true:
			button.disabled = false

func _on_LineEdit2_text_changed(new_text):
	if new_text == "":
		thing_entered = false
		button.disabled = true
	else:
		thing_entered = true
		if name_entered == true:
			button.disabled = false
