extends Control

onready var up_key = $VBoxContainer/CenterContainer/Controls/HBoxContainer/VBoxContainer2/ForwardKeyButton/ForwardKey
onready var down_key = $VBoxContainer/CenterContainer/Controls/HBoxContainer/VBoxContainer2/BackwardKeyButton/BackwardKey
onready var left_key = $VBoxContainer/CenterContainer/Controls/HBoxContainer/VBoxContainer2/LeftKeyButton/LeftKey
onready var right_key = $VBoxContainer/CenterContainer/Controls/HBoxContainer/VBoxContainer2/RightKeyButton/RightKey
onready var shoot_key = $VBoxContainer/CenterContainer/Controls/HBoxContainer/VBoxContainer2/ShootKeyButton/ShootKey
onready var convo_key = $VBoxContainer/CenterContainer/Controls/HBoxContainer/VBoxContainer2/ConvoKeyButton/ConvoKey

onready var key_wait_panel = $KeyWaitPanel

enum Controls { UP=0, DOWN, LEFT, RIGHT, SHOOT, CONVO }

var control_labels
var control_actions = [ "move_up", "move_down", "move_left", "move_right", "shoot_gun", "convo_continue" ]
var button_indexes = { 1: "Left Mouse", 2: "Right Mouse", 3: "Middle Mouse" }

var wait_key = false
var control_item

func _ready():
	key_wait_panel.hide()
	control_labels = [ up_key, down_key, left_key, right_key, shoot_key, convo_key ]

func update_keys():
	for control_index in range(0, control_labels.size()):
		var action_list = InputMap.get_action_list(control_actions[control_index])
		var action = action_list[0]
		if action is InputEventKey:
			control_labels[control_index].set_text(OS.get_scancode_string(action.scancode))
		elif action is InputEventMouseButton:
			control_labels[control_index].set_text(button_indexes[action.button_index])

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
		
		# check for mouse event
		if event is InputEventMouseButton:
			wait_key = false
			key_wait_panel.hide()
			#update input map
			InputMap.action_erase_events(control_actions[control_item])
			InputMap.action_add_event(control_actions[control_item], event)
			# update key text on menu
			control_labels[control_item].set_text(button_indexes[event.button_index])


# called whenever user clicks to rebind a key
func _on_control_key_button_pressed(key:int):
	key_wait_panel.show()
	wait_key = true
	control_item = key

func _on_ReturnToMenuButton_pressed():
	GameManager.return_to_menu()
