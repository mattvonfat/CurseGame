extends Node2D

onready var boss_scene = preload("res://entities/enemies/BossMonster.tscn")
onready var rock_boss_scene = preload("res://entities/enemies/RockBoss.tscn")
onready var enemy_scene = preload("res://entities/enemies/Enemy.tscn")
onready var treasure_scene = preload("res://Treasure.tscn")

onready var floor_tile_scene = preload("res://tiles/FloorTile.tscn")
onready var wall_tile_scene = preload("res://tiles/WallTile.tscn")
onready var floor_spike_tile_scene = preload("res://tiles/FloorSpikeTile.tscn")
onready var boss_door_tile_scene = preload("res://tiles/BossDoorTile.tscn")

onready var tile_collection = $Tiles
onready var enemy_collection = $Enemies
onready var pickup_collection = $Pickups
onready var player_collection = $Player
onready var gui = $GUI

enum { NORTH=0, SOUTH=1, EAST=2, WEST=3 }

var player

var rng:RandomNumberGenerator

var player_start_position = Vector2(80, 48)

var visited_rooms = []
var current_room : int

var empty_tiles = []

var boss_door_tile
var room_enemy_count : Array
var room_doors : Array

func _ready():
	GameManager.game = self
	rng = RandomNumberGenerator.new()
	rng.randomize()
	$GUI/PauseMenu.connect("update_settings", self, "_on_update_settings")

func load_level(data):	
	var new_tile
	var row_pos
	var col_pos
	current_room = 1
	
	var previous_exit_direction
	var previous_exit_position
	var previous_room_width
	var previous_room_height
	
	var row_pos_default
	var enemy_counter
	
	room_enemy_count = []
	room_doors = []
	
	var level_data = data["data"]
	
	for room in level_data:
		room_enemy_count.append(0)
		room_doors.append(0)
		
		enemy_counter = 0
		# check whether it is the first room so we can calculate the drawing offset
		if room["id"] == 1:
			# first room so can start from the origin
			row_pos = 0
			col_pos = 0
			row_pos_default = 0
		else:
			# need to follow on from previous room's exit
			var room_entry_position = room["entry_position"]
			match previous_exit_direction:
				NORTH:
					col_pos = col_pos - (previous_room_height * 32) - (room["height"] * 32)
					row_pos = row_pos + (previous_exit_position.x * 32) - (room_entry_position.x * 32)
					row_pos_default = row_pos
				SOUTH:
					# col_pos stays the same
					row_pos = row_pos + (previous_exit_position.x * 32) - (room_entry_position.x * 32)
					row_pos_default = row_pos
				EAST:
					row_pos = row_pos + (previous_room_width * 32)
					row_pos_default = row_pos
					col_pos = col_pos - (previous_room_height * 32) + (previous_exit_position.y * 32) - (room_entry_position.y * 32)
				WEST:
					row_pos = row_pos - (room["width"] * 32)
					row_pos_default = row_pos
					col_pos = col_pos - (previous_room_height * 32) + (previous_exit_position.y * 32) - (room_entry_position.y * 32)
		
		for tile_row in room["data"]:
			for tile in tile_row:
				match tile:
					GameData.TileTypes.WALL_TILE:
						new_tile = wall_tile_scene.instance()
					
					GameData.TileTypes.SAFE_FLOOR_TILE:
						new_tile = floor_tile_scene.instance()
						empty_tiles.append(new_tile)
						new_tile.room_type = room["room_type"]
						new_tile.set_as_safe()
					
					GameData.TileTypes.FLOOR_TILE:
						new_tile = floor_tile_scene.instance()
						empty_tiles.append(new_tile)
						new_tile.room_type = room["room_type"]
					
					GameData.TileTypes.SPIKE_TILE:
						new_tile = floor_spike_tile_scene.instance()
					
					GameData.TileTypes.BOSS_DOOR:
						new_tile = boss_door_tile_scene.instance()
						new_tile.set_room_direction(room["exit_direction"])
						boss_door_tile = new_tile
					
					GameData.TileTypes.ENEMY_DOOR:
						new_tile = boss_door_tile_scene.instance()
						new_tile.set_room_direction(room["exit_direction"])
						room_doors[room["id"]-1] = new_tile
				
				tile_collection.add_child(new_tile)
				new_tile.set_room_number(room["id"])
				new_tile.connect("player_entered", self, "_on_player_entered")
				new_tile.position = Vector2(row_pos,col_pos)
				if room["id"] != current_room:
					new_tile.hide_tile()
				row_pos += 32
			row_pos = row_pos_default
			col_pos += 32
		
		if room["room_type"] == "STARTING":
			player.position = Vector2(row_pos_default+(room["width"]*16)-16,col_pos-(room["height"]*16)-16)
			print(player.position)
		
		if room["room_type"] == "ENEMY":
			var enemy_count = room["enemy_count"]
			for i in range(0,enemy_count):
				var new_enemy = enemy_scene.instance()
				enemy_collection.add_child(new_enemy)
				new_enemy.set_room_number(room["id"])
				new_enemy.connect("enemy_died", self, "_on_enemy_died")
				new_enemy.set_player(player)
				room_enemy_count[room["id"]-1] += 1
				match room["entry_direction"]:
					NORTH:
						new_enemy.position = Vector2(row_pos_default+(32)+(32*i),col_pos-(80))
					SOUTH:
						new_enemy.position = Vector2(row_pos_default+(32)+(32*i),col_pos-((room["height"]-1)*32))
					EAST:
						new_enemy.position = Vector2(row_pos_default+(room["width"]*16)-16-(32*i),col_pos-(room["height"]*16)-16-(32*i))
					WEST:
						new_enemy.position = Vector2(row_pos_default+(room["width"]*16)-16-(32*i),col_pos-(room["height"]*16)-16-(32*i))
		
		if room["room_type"] == "BOSS":
			var new_enemy = rock_boss_scene.instance()
			enemy_collection.add_child(new_enemy)
			new_enemy.position = Vector2(row_pos_default+(room["width"]*16)-16,col_pos-(room["height"]*16)-16)
			new_enemy.set_room_number(room["id"])
			new_enemy.connect("enemy_died", self, "_on_enemy_died")
			new_enemy.set_player(player)
			
		if room["room_type"] == "TREASURE":
			var new_treasure = treasure_scene.instance()
			pickup_collection.add_child(new_treasure)
			new_treasure.set_room_number(room["id"])
			new_treasure.connect("picked_up", self, "_on_treasure_picked_up")
			new_treasure.set_treasure(data["treasure"])
			new_treasure.position = Vector2(row_pos_default+(room["width"]*16)-10,col_pos-(room["height"]*16)-10)
		
		# if this isn't the last room then store the exit position
		if room["id"] != level_data.size():
			previous_exit_direction = room["exit_direction"]
			previous_exit_position = room["exit_position"]
			previous_room_width = room["width"]
			previous_room_height = room["height"]
	
	update_visibility()
	gui.initialise(player)
	$AudioStreamPlayer.play()

func update_visibility():
	var tiles = tile_collection.get_children()
	for tile in tiles:
		if tile.get_room_number() == current_room:
			tile.show_tile()
		else:
			tile.hide_tile()
	
	var enemies = enemy_collection.get_children()
	for enemy in enemies:
		if enemy.get_room_number() == current_room:
			enemy.show_enemy()
		else:
			enemy.hide_enemy()
	
	var pickups = pickup_collection.get_children()
	for pickup in pickups:
		if pickup.get_room_number() == current_room:
			pickup.show_pickup()
		else:
			pickup.hide_pickup()

func _on_BreakCheck_timeout():
	var break_tile = GameManager.tile_break_check()
	
	if visited_rooms.size() > 0:
		if break_tile == true:
			print(empty_tiles.size())
			var valid_tile = false
			while valid_tile == false:
				var tile_num = rng.randi_range(0,empty_tiles.size()-1)
				var selected_tile = empty_tiles[tile_num]
				if selected_tile.get_room_type() != "TREASURE" and visited_rooms.has(selected_tile.get_room_number()):
					selected_tile.start_break()
					valid_tile = true
		



func _process(_delta):
	pass

func break_tile():
	pass

func _on_player_entered(room_number, damaged, tile):
	tile.set_player(player)
	
	if current_room != room_number:
		current_room = room_number
		if visited_rooms.has(room_number) == false:
			visited_rooms.append(room_number)
		update_visibility()
	
	if damaged == true:
		player.do_damage(5)



func _on_enemy_died(enemy_reference):
	var enemy_type = enemy_reference.get_enemy_type()
	
	match enemy_type:
		"BOSS":
			boss_door_tile.open_door()
		
		"STANDARD":
			var room_id = enemy_reference.get_room_number()
			var room_index = room_id-1
			room_enemy_count[room_index] -= 1
			if room_enemy_count[room_index] == 0:
				room_doors[room_index].open_door()

func _on_treasure_picked_up(_treasure_reference):
	GameManager.level_completed()


func add_player_node(player_node):
	player = player_node
	player_collection.add_child(player)

func remove_player_node():
	player_collection.remove_child(player)


# pause menu closed so update the volume in case they changed it
func _on_update_settings():
	GameManager.update_volumes()
