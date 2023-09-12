extends Node

onready var main_menu_scene : PackedScene = preload("res://menus/MainMenu.tscn")
onready var controls_menu_scene : PackedScene = preload("res://menus/Controls.tscn")
onready var user_input_scene : PackedScene = preload("res://menus/UserInfo.tscn")
onready var story_scene : PackedScene = preload("res://menus/Story.tscn")
onready var level_select_scene : PackedScene = preload("res://menus/LevelSelectScreen.tscn")
onready var game_world_scene : PackedScene = preload("res://GameWorld.tscn")
onready var player_scene : PackedScene = preload("res://Player.tscn")
onready var bullet_scene : PackedScene = preload("res://entities/Bullet.tscn")
onready var rock_scene : PackedScene = preload("res://Rock.tscn")
onready var death_screen_scene : PackedScene = preload("res://menus/DeathScreen.tscn")
onready var win_screen_scene : PackedScene = preload("res://menus/WinScreen.tscn")

onready var game_data : Resource = preload("res://scripts/level_data.tres")

enum { HEALTH_DEGEN=0, REDUCED_SPEED, SLOWER_SHOOTING, MISS_CHANCE, ENEMY_DAMAGE }
enum { SPLASH=0, MAIN_MENU, CONTROL_MENU, USER_INPUT, STORY, LEVEL_SELECT, LEVEL, END_STORY, DEAD, WIN }

var control_actions = [ "move_up", "move_down", "move_left", "move_right", "shoot_gun", "convo_continue" ]
var button_indexes = { 1: "Left Mouse", 2: "Right Mouse", 3: "Middle Mouse" }

var nodes = ["Splash", "MainMenu", "Controls", "UserInfo", "Story", "LevelSelectScreen", "GameWorld"]

var rng:RandomNumberGenerator

var game
var player

var paused = false

var current_level : int = 0

var active_curses : Array

var main_menu_node
var controls_menu_node

var user_item

var game_state

var rooms_per_level = 8
var music_volume = 100

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	load_config()
	
	game_state = SPLASH

func load_config():
	var config = ConfigFile.new()
	var error = config.load("user://settings.cfg")
	
	if error != OK:
		create_config_file(config)
	else:
		for control_index in range(0, control_actions.size()):
			var control_type = config.get_value(control_actions[control_index], "type")
			var control_key = config.get_value(control_actions[control_index], "key")
			
			if control_type == "key":
				var event = InputEventKey.new()
				event.scancode = control_key
				InputMap.action_erase_events(control_actions[control_index])
				InputMap.action_add_event(control_actions[control_index], event)
			elif control_type == "mouse":
				var event = InputEventMouseButton.new()
				event.button_index = control_key
				InputMap.action_erase_events(control_actions[control_index])
				InputMap.action_add_event(control_actions[control_index], event)
		rooms_per_level = config.get_value("level_rooms", "number", rooms_per_level)
		music_volume = config.get_value("music_volume", "volume", music_volume)

func create_config_file(config : ConfigFile):
	for control_index in range(0, control_actions.size()):
		var action_list = InputMap.get_action_list(control_actions[control_index])
		var action = action_list[0]
		if action is InputEventKey:
			config.set_value(control_actions[control_index], "type", "key")
			config.set_value(control_actions[control_index], "key", action.scancode)
		elif action is InputEventMouseButton:
			config.set_value(control_actions[control_index], "type", "mouse")
			config.set_value(control_actions[control_index], "key", action.button_index)
	config.set_value("level_rooms", "number", rooms_per_level)
	config.set_value("music_volume", "volume", music_volume)
	config.save("user://settings.cfg")

func save_settings():
	var config = ConfigFile.new()
	var error = config.load("user://settings.cfg")
	
	if error != OK:
		print(error)
	
	for control_index in range(0, control_actions.size()):
		var action_list = InputMap.get_action_list(control_actions[control_index])
		var action = action_list[0]
		if action is InputEventKey:
			config.set_value(control_actions[control_index], "key", action.scancode)
		elif action is InputEventMouseButton:
			config.set_value(control_actions[control_index], "mouse", action.button_index)
	config.set_value("level_rooms", "number", rooms_per_level)
	config.set_value("music_volume", "volume", music_volume)
	config.save("user://settings.cfg")

func splash_to_menu():
	var splash_screen = get_tree().get_root().get_node("SplashScreen")
	get_tree().get_root().remove_child(splash_screen)
	splash_screen.queue_free()
	
	start_main_menu()

func start_main_menu():
	main_menu_node = main_menu_scene.instance()
	controls_menu_node = controls_menu_scene.instance()
	
	get_tree().get_root().add_child(main_menu_node)
	
	game_state = MAIN_MENU


# move to control menu
func go_to_controls_menu():
	get_tree().get_root().remove_child(main_menu_node)
	get_tree().get_root().add_child(controls_menu_node)
	controls_menu_node.update_keys()
	game_state = CONTROL_MENU

# return to main menu from control menu
func return_to_menu(changes:bool):
	get_tree().get_root().remove_child(controls_menu_node)
	get_tree().get_root().add_child(main_menu_node)
	if changes == true:
		save_settings()
	game_state = MAIN_MENU

# goes to story input when new game starts
func start_new_game():
	game_data.generate_game()
	player = player_scene.instance()
	active_curses = []
	
	var user_input_node = user_input_scene.instance()
	
	get_tree().get_root().remove_child(main_menu_node)
	get_tree().get_root().add_child(user_input_node)
	
	main_menu_node.queue_free()
	controls_menu_node.queue_free()
	
	game_state = USER_INPUT

func go_to_story(user_name, user_thing):
	var user_input_node = get_tree().get_root().get_node("UserInfo")
	var story_node = story_scene.instance()
	user_item = user_thing
	get_tree().get_root().remove_child(user_input_node)
	get_tree().get_root().add_child(story_node)
	
	story_node.start_story(user_name, user_thing)
	game_state = STORY

func go_to_level_select():
	var existing_node
	var new_level_selector = level_select_scene.instance()
	
	if game_state == STORY:
		existing_node = get_tree().get_root().get_node("Story")
	
	get_tree().get_root().remove_child(existing_node)
	get_tree().get_root().add_child(new_level_selector)
	
	new_level_selector.update_level_menu(game_data.get_level_info())
	
	game_state = LEVEL_SELECT


func load_level(level_number):
	var level_select_node = get_tree().get_root().get_node("LevelSelectScreen")
	var new_game_world = game_world_scene.instance()
	
	get_tree().get_root().remove_child(level_select_node)
	get_tree().get_root().add_child(new_game_world)
	
	var level_data = game_data.get_level_data(level_number)
	new_game_world.add_player_node(player)
	new_game_world.load_level(level_data)
	current_level = level_number
	
	player.reset_player()
	
	level_select_node.queue_free()
	game_state = LEVEL

func return_to_level_select():
	var game_world_node = get_tree().get_root().get_node("GameWorld")
	var new_level_selector = level_select_scene.instance()
	game_world_node.remove_player_node()
	
	get_tree().get_root().call_deferred("remove_child", game_world_node)
	get_tree().get_root().add_child(new_level_selector)
	
	new_level_selector.update_level_menu(game_data.get_level_info())
	
	game_world_node.queue_free()
	game_state = LEVEL_SELECT

func player_died():
	game_state = DEAD
	
	var game_world_node = get_tree().get_root().get_node("GameWorld")
	var new_death_screen = death_screen_scene.instance()
	
	game_world_node.remove_player_node()
	
	get_tree().get_root().call_deferred("remove_child", game_world_node)
	get_tree().get_root().add_child(new_death_screen)
	
	game_world_node.queue_free()
	

func tile_break_check() -> bool:
	var random_number = rng.randi_range(1,10)
	
	if random_number == 5:
		return true
	
	return false


func fire_bullet(start_point : Vector2, direction : Vector2):
	var new_bullet = bullet_scene.instance()
	game.add_child(new_bullet)
	new_bullet.position = start_point
	new_bullet.initiate(direction)

func throw_rock(start_point : Vector2, direction : Vector2):
	var new_rock = rock_scene.instance()
	game.add_child(new_rock)
	new_rock.position = start_point
	new_rock.initiate(direction)

func level_completed():
	var all_levels_complete = game_data.set_level_complete(current_level)
	var curse = game_data.get_level_curse(current_level)
	process_curse(curse)
	
	if all_levels_complete == true:
		win_game()
	else:
		return_to_level_select()
	

func win_game():
	var game_world_node = get_tree().get_root().get_node("GameWorld")
	var new_win_screen = win_screen_scene.instance()
	
	game_world_node.remove_player_node()
	
	get_tree().get_root().call_deferred("remove_child", game_world_node)
	get_tree().get_root().add_child(new_win_screen)
	
	new_win_screen.set_item(user_item)
	
	game_state = WIN

func process_curse(curse):
	match curse:
		HEALTH_DEGEN:
			active_curses.append(HEALTH_DEGEN)
			player.add_health_degen()
		
		REDUCED_SPEED:
			active_curses.append(REDUCED_SPEED)
			player.reduce_speed()
		
		SLOWER_SHOOTING:
			active_curses.append(SLOWER_SHOOTING)
			player.slow_shooting()
		
		MISS_CHANCE:
			active_curses.append(MISS_CHANCE)
		
		ENEMY_DAMAGE:
			active_curses.append(ENEMY_DAMAGE)

func has_damage_curse():
	if active_curses.has(ENEMY_DAMAGE):
		return true
	return false

func get_attack_multiplier():
	if has_damage_curse():
		return 1.5
	return 1

func has_miss_curse():
	if active_curses.has(MISS_CHANCE):
		return true
	return false

func shot_missed():
	if has_miss_curse():
		var num = rng.randi_range(1,10)
		if num == 5:
			return true
	return false

func get_active_curses():
	return active_curses



# goes back to main menu
func exit_game():
	var current_node
	var main
	
	get_tree().paused = false
	
	if game_state == LEVEL_SELECT:
		current_node = get_tree().get_root().get_node("LevelSelectScreen")
	elif game_state == STORY:
		current_node = get_tree().get_root().get_node("Story")
	elif game_state == DEAD:
		current_node = get_tree().get_root().get_node("DeathScreen")
	elif game_state == WIN:
		current_node = get_tree().get_root().get_node("WinScreen")
	else:
		current_node = get_tree().get_root().get_node("GameWorld")
	
	player.queue_free()
	get_tree().get_root().remove_child(current_node)
	
	start_main_menu()


func game_paused():
	paused = true
	get_tree().paused = true

func game_unpaused():
	paused = false
	get_tree().paused = false

func is_game_paused():
	return paused

