extends Node2D

func _ready():
	print(90)

func _on_NewGame_pressed():
	print(1)
	GameManager.start_new_game()


func _on_Controls_pressed():
	GameManager.go_to_controls_menu()
