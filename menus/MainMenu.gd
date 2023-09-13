extends Node2D

var action

func _on_NewGame_pressed():
	action = "NEW"
	$ButtonClick.play()


func _on_Controls_pressed():
	action = "CONTROLS"
	$ButtonClick.play()


func _on_button_mouse_entered():
	$ButtonHover.play()


func _on_ButtonClick_finished():
	if action == "NEW":
		GameManager.start_new_game()
	else:
		GameManager.go_to_controls_menu()
