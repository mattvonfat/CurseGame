extends Node2D

onready var timer = $Timer
onready var hell_front = $HellHoleFront
onready var hell_back = $HellHoleBack
onready var sun = $Sun
onready var devil = $Devil
onready var text_panel = $CanvasLayer/MarginContainer/Panel
onready var speaker = $CanvasLayer/MarginContainer/Panel/MarginContainer/VBoxContainer/Speaker
onready var text = $CanvasLayer/MarginContainer/Panel/MarginContainer/VBoxContainer/Text
onready var deal_panel = $CanvasLayer/MarginContainer/Panel2
onready var player = $Player
onready var continue_label = $CanvasLayer/MarginContainer/Panel/MarginContainer/VBoxContainer/Continue

var timings = [0.1, 0.5, 0.5, 0.01, 0.5]
var step_counter

var button_indexes = { 1: "Left Mouse", 2: "Right Mouse", 3: "Middle Mouse" }

var user_name : String
var user_thing : String

func _ready():
	text_panel.hide()
	deal_panel.hide()
	
	var ae = InputMap.get_action_list("convo_continue")
	if ae[0] is InputEventKey:
		continue_label.set_text("<%s>" % OS.get_scancode_string(ae[0].scancode))
	elif ae[0] is InputEventMouseButton:
		var button = ae[0].button_index
		continue_label.set_text("<%s>" % button_indexes[button])

func start_story(_user_name, _user_thing):
	user_name = _user_name
	user_thing = _user_thing
	step_counter = -2
	timer.set_wait_time(timings[step_counter])
	timer.start()

func _process(_delta):
	if step_counter == -1:
		if Input.is_action_just_pressed("convo_continue"):
			match step_counter:
				-1:
					step_counter = 0
					timer.set_wait_time(timings[step_counter])
					timer.start()
	
	if step_counter > 4:
		if Input.is_action_just_pressed("convo_continue"):
			match step_counter:
				5:
					speaker.set_text("%s:" % user_name)
					text.set_text("Uh... yeah I did...")
					step_counter += 1
				
				6:
					speaker.set_text("The Devil:")
					text.set_text("Oh, well I can help you with that! My name is The Devil.")
					step_counter += 1
				
				7:
					text.set_text("If you help me with a task I will give you %s as a reward." % user_thing)
					step_counter += 1
				
				8:
					speaker.set_text("%s:" % user_name)
					text.set_text("This seems a bit suspicious, you are the devil after all. How am I meant to trust you?")
					step_counter += 1
				
				9:
					speaker.set_text("The Devil:")
					text.set_text("Your doubt is understandable, however a deal with the devil is legally binding so if you agree to help me, and succeed in your task, I have to give you what you want.")
					step_counter += 1
				
				10:
					text.set_text("Also, I have to give you exactly what you want. I'm not some hack genie who will give you a messed up verion of your wish. If you help me you get %s." % user_thing)
					step_counter += 1
				
				11:
					speaker.set_text("%s:" % user_name)
					text.set_text("Ok then, what do you want me to do?")
					step_counter += 1
				
				12:
					sun.set_frame(2)
					speaker.set_text("The Devil:")
					text.set_text("I need you to visit four temples and retrieve the artifacts hidden within. I'd do it my self, however my power isn't what it once was...")
					step_counter += 1
				
				13:
					text.set_text("But with these four artifacts I will be able to get to my full strength and give you the %s you desire." % user_thing)
					step_counter += 1
				
				14:
					text.set_text("So do we have a deal?")
					step_counter += 1
				
				15:
					text_panel.hide()
					deal_panel.show()

func _on_Timer_timeout():
	match step_counter:
		-2:
			text_panel.show()
			speaker.set_text("%s:" % user_name)
			text.set_text("*sigh* I wish I had %s." % user_thing)
			step_counter = -1
			
		0:
			text_panel.hide()
			hell_back.set_frame(1)
			hell_front.set_frame(1)
			step_counter += 1
			timer.set_wait_time(timings[step_counter])
			timer.start()
		
		1:
			player.set_frame(1)
			hell_front.set_frame(2)
			step_counter += 1
			timer.set_wait_time(timings[step_counter])
			timer.start()
		
		2:
			hell_front.set_frame(3)
			step_counter += 1
			timer.set_wait_time(timings[step_counter])
			timer.start()
		
		3:
			devil.position.y -= 1
			if devil.position.y == 400:
				sun.set_frame(1)
			if devil.position.y == 280:
				player.set_frame(2)
			if devil.position.y == 210:
				step_counter += 1
			timer.set_wait_time(timings[step_counter])
			timer.start()
		
		4:
			text_panel.show()
			speaker.set_text("The Devil:")
			text.set_text("Did somebody say %s?" % user_thing)
			step_counter += 1


func _on_SkipCutscene_pressed():
	GameManager.go_to_level_select()


func _on_DealButton_pressed():
	GameManager.go_to_level_select()


func _on_NoDealButton_pressed():
	GameManager.exit_game()
