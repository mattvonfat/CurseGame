extends Control

signal leave_menu

onready var up_key = $VBoxContainer/CenterContainer/VBoxContainer/Controls/HBoxContainer/VBoxContainer2/ForwardKeyButton/ForwardKey
onready var down_key = $VBoxContainer/CenterContainer/VBoxContainer/Controls/HBoxContainer/VBoxContainer2/BackwardKeyButton/BackwardKey
onready var left_key = $VBoxContainer/CenterContainer/VBoxContainer/Controls/HBoxContainer/VBoxContainer2/LeftKeyButton/LeftKey
onready var right_key = $VBoxContainer/CenterContainer/VBoxContainer/Controls/HBoxContainer/VBoxContainer2/RightKeyButton/RightKey
onready var shoot_key = $VBoxContainer/CenterContainer/VBoxContainer/Controls/HBoxContainer/VBoxContainer2/ShootKeyButton/ShootKey
onready var convo_key = $VBoxContainer/CenterContainer/VBoxContainer/Controls/HBoxContainer/VBoxContainer2/ConvoKeyButton/ConvoKey

onready var music_volume_slider = $VBoxContainer/CenterContainer/VBoxContainer/SoundSettings/HBoxContainer/VBoxContainer2/MusicSlider
onready var sfx_volume_slider = $VBoxContainer/CenterContainer/VBoxContainer/SoundSettings/HBoxContainer/VBoxContainer2/SFXSlider
onready var gui_volume_slider = $VBoxContainer/CenterContainer/VBoxContainer/SoundSettings/HBoxContainer/VBoxContainer2/GUISlider3

onready var key_wait_panel = $KeyWaitPanel

enum Controls { UP=0, DOWN, LEFT, RIGHT, SHOOT, CONVO }

var control_labels
var control_actions = [ "move_up", "move_down", "move_left", "move_right", "shoot_gun", "convo_continue" ]
var button_indexes = { 1: "Left Mouse", 2: "Right Mouse", 3: "Middle Mouse" }

var wait_key = false
var control_item

var changes = false

var is_pause_menu:bool = false

func _ready():
	key_wait_panel.hide()
	control_labels = [ up_key, down_key, left_key, right_key, shoot_key, convo_key ]
	
func update_keys(pause_menu:bool=false):
	changes = false
	for control_index in range(0, control_labels.size()):
		var action_list = InputMap.get_action_list(control_actions[control_index])
		var action = action_list[0]
		if action is InputEventKey:
			control_labels[control_index].set_text(OS.get_scancode_string(action.scancode))
		elif action is InputEventMouseButton:
			control_labels[control_index].set_text(button_indexes[action.button_index])
	$VBoxContainer/CenterContainer/VBoxContainer/GameSettings/HBoxContainer/VBoxContainer2/LevelRooms.set_value(GameManager.rooms_per_level)
	music_volume_slider.set_value(GameManager.music_volume)
	sfx_volume_slider.set_value(GameManager.sfx_volume)
	gui_volume_slider.set_value(GameManager.gui_volume)
	
	# added this in so i can reuse the controls menu on the pause screen
	# need to stop it asking GameManager to go back to the main menu
	if pause_menu == true:
		is_pause_menu = true
		# chnaging the game settings (number of rooms) doesn't affect the game once it has started so just hide it if in pause menu
		$VBoxContainer/CenterContainer/VBoxContainer/GameSettings.hide()

func _input(event):
	if wait_key:
		# check for key press
		if event is InputEventKey:
			wait_key = false
			key_wait_panel.hide()
			# update input map
			InputMap.action_erase_events(control_actions[control_item])
			InputMap.action_add_event(control_actions[control_item], event)
			# update key text on menu
			control_labels[control_item].set_text(OS.get_scancode_string(event.physical_scancode))
			changes = true
		
		# check for mouse event
		if event is InputEventMouseButton:
			wait_key = false
			key_wait_panel.hide()
			#update input map
			InputMap.action_erase_events(control_actions[control_item])
			InputMap.action_add_event(control_actions[control_item], event)
			# update key text on menu
			control_labels[control_item].set_text(button_indexes[event.button_index])
			changes = true


# called whenever user clicks to rebind a key
func _on_control_key_button_pressed(key:int):
	key_wait_panel.show()
	wait_key = true
	control_item = key

func _on_ReturnToMenuButton_pressed():
	if is_pause_menu == true:
		# if we're in the pause menu then emit the leave menu signal but also check if we need to save and if so do it
		# this is a quick fix as I don't want to rewrite everything and just want to add this in the pause menu
		if changes == true:
			GameManager.save_settings()
		emit_signal("leave_menu")
	else:
		GameManager.return_to_menu(changes)


func _on_LevelRooms_value_changed(value):
	changes = true
	GameManager.rooms_per_level = value


func _on_Music_Slider_value_changed(value):
	GameManager.music_volume = value
	changes = true


func _on_GUISlider3_value_changed(value):
	GameManager.gui_volume = value
	changes = true


func _on_SFXSlider_value_changed(value):
	GameManager.sfx_volume = value
	changes = true


func _on_ReturnToMenuButton_mouse_entered():
	$AudioStreamPlayer.play()


func _on_button_mouse_entered():
	$AudioStreamPlayer.play()
