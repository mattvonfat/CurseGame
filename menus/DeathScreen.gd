extends Node2D



func _on_MainMenu_pressed():
	GameManager.exit_game()


func _on_MainMenu_mouse_entered():
	$AudioStreamPlayer.play()
