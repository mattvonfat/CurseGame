extends Node2D


func _on_NewGame_pressed():
	GameManager.start_new_game()


func _on_Controls_pressed():
	GameManager.go_to_controls_menu()
