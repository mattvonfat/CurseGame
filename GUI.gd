extends CanvasLayer

onready var health_degen_icon = preload("res://images/curses/degen_icon.png")
onready var slow_movement_icon = preload("res://images/curses/slow_icon.png")
onready var slow_shooting_icon = preload("res://images/curses/slow_shoot_icon.png")

onready var health_bar = $VBoxContainer/MarginContainer/HBoxContainer/HealthBar
onready var health_text = $VBoxContainer/MarginContainer/HBoxContainer/HealthBar/HealthText

onready var curse_icons = [
	$VBoxContainer/MarginContainer2/HBoxContainer/Curse1,
	$VBoxContainer/MarginContainer2/HBoxContainer/Curse2,
	$VBoxContainer/MarginContainer2/HBoxContainer/Curse3
]

enum { HEALTH_DEGEN=0, REDUCED_SPEED, SLOWER_SHOOTING, MISS_CHANCE, ENEMY_DAMAGE }

var player
var max_health

func initialise(player_reference):
	player = player_reference
	player.connect("health_update", self, "_on_player_health_update")
	max_health = player.get_max_health()
	
	health_bar.set_max(max_health)
	health_bar.set_value(max_health)
	
	health_text.set_text("%s/%s" % [max_health, max_health])
	
	var curse_count = 0
	var curses = GameManager.get_active_curses()
	for curse in curses:
		match curse:
			HEALTH_DEGEN:
				curse_icons[curse_count].set_texture(health_degen_icon)
			
			REDUCED_SPEED:
				curse_icons[curse_count].set_texture(slow_movement_icon)
			
			SLOWER_SHOOTING:
				curse_icons[curse_count].set_texture(slow_shooting_icon)
		
		curse_count += 1

func _on_player_health_update(new_health):
	health_bar.set_value(new_health)	
	health_text.set_text("%s/%s" % [new_health, max_health])
