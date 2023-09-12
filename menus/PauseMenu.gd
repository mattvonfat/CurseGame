extends Control

signal update_settings

func _ready():
	hide()
	$Controls.hide()
	$Controls.connect("leave_menu", self, "_on_leave_controls_menu")

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

func _on_SettingsButton_pressed():
	$Controls.update_keys(true)
	$Controls.show()

func _on_leave_controls_menu():
	$Controls.hide()
	emit_signal("update_settings")
