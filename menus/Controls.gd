extends Control

onready var up_key = $VBoxContainer/CenterContainer/VBoxContainer/Controls/HBoxContainer/VBoxContainer2/ForwardKeyButton/ForwardKey
onready var down_key = $VBoxContainer/CenterContainer/VBoxContainer/Controls/HBoxContainer/VBoxContainer2/BackwardKeyButton/BackwardKey
onready var left_key = $VBoxContainer/CenterContainer/VBoxContainer/Controls/HBoxContainer/VBoxContainer2/LeftKeyButton/LeftKey
onready var right_key = $VBoxContainer/CenterContainer/VBoxContainer/Controls/HBoxContainer/VBoxContainer2/RightKeyButton/RightKey
onready var shoot_key = $VBoxContainer/CenterContainer/VBoxContainer/Controls/HBoxContainer/VBoxContainer2/ShootKeyButton/ShootKey
onready var convo_key = $VBoxContainer/CenterContainer/VBoxContainer/Controls/HBoxContainer/VBoxContainer2/ConvoKeyButton/ConvoKey

onready var music_volume_label = $VBoxContainer/CenterContainer/VBoxContainer/SoundSettings/HBoxContainer/VBoxContainer3/TextureButton2/MusicVolumeLabel
onready var music_volume_slider = $VBoxContainer/CenterContainer/VBoxContainer/SoundSettings/HBoxContainer/VBoxContainer2/MusicSlider

onready var key_wait_panel = $KeyWaitPanel

enum Controls { UP=0, DOWN, LEFT, RIGHT, SHOOT, CONVO }

var control_labels
var control_actions = [ "move_up", "move_down", "move_left", "move_right", "shoot_gun", "convo_continue" ]
var button_indexes = { 1: "Left Mouse", 2: "Right Mouse", 3: "Middle Mouse" }

var wait_key = false
var control_item

var changes = false

func _ready():
	key_wait_panel.hide()
	control_labels = [ up_key, down_key, left_key, right_key, shoot_key, convo_key ]
	music_volume_slider.set_step(0.001)
	music_volume_label.set_text("%s%%" % (floor(music_volume_slider.value*200)))# multiply by 200 as it's between 0 and 0.5, so need to double it for percentage

func update_keys():
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
	GameManager.return_to_menu(changes)


func _on_LevelRooms_value_changed(value):
	changes = true
	GameManager.rooms_per_level = value


func _on_Music_Slider_value_changed(value):
	music_volume_label.set_text("%s%%" % (floor(value*200))) # multiply by 200 as it's between 0 and 0.5, so need to double it for percentage
	GameManager.music_volume = value
	changes = true
