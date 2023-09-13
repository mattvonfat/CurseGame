extends Node2D

onready var item_text = $Label

func set_item(text):
	item_text.set_text(text)

func _on_MainMenu_pressed():
	GameManager.exit_game()


func _on_MainMenu_mouse_entered():
	$AudioStreamPlayer.play()
