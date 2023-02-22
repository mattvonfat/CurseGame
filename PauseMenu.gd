extends Control


func _ready():
	hide()

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if GameManager.is_game_paused():
			hide()
			GameManager.game_unpaused()
		else:
			show()
			GameManager.game_paused()

func _on_ResumeButton_pressed():
	GameManager.game_unpaused()
	hide()


func _on_ExitButton_pressed():
	hide()
	GameManager.exit_game()
