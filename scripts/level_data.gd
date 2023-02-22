extends Resource

enum { NORTH=0, SOUTH=1, EAST=2, WEST=3 }

var rng:RandomNumberGenerator

var level_info : Array = []

func _init():
	rng = RandomNumberGenerator.new()
	rng.randomize()


func generate_game():
	level_info.clear()
	var selected_curses = []
	var selected_names = []
	var selected_treasures = []
	
	for level_number in range(1,5):
		var info : Dictionary = {}
		
		info["id"] = level_number
		info["completed"] = false
		info["data"] = generate_level()
		
		var curse_number = rng.randi_range(0,GameData.Curses.size()-1)
		while selected_curses.has(curse_number):
			curse_number = rng.randi_range(0,GameData.Curses.size()-1)
		selected_curses.append(curse_number)
		info["curse"] = curse_number
		
		var name_number = rng.randi_range(0,GameData.temple_names.size()-1)
		while selected_names.has(name_number):
			name_number = rng.randi_range(0,GameData.temple_names.size()-1)
		selected_names.append(name_number)
		info["name"] = GameData.temple_names[name_number]
		
		var treasure_number = rng.randi_range(0, GameData.treasure_list.size()-1)
		while selected_treasures.has(treasure_number):
			treasure_number = rng.randi_range(0,GameData.treasure_list.size()-1)
		selected_treasures.append(treasure_number)
		info["treasure"] = treasure_number
		
		level_info.append(info)

func get_level_info():
	return level_info

func get_level_data(level_number):
	return level_info[level_number-1]

func set_level_complete(level_number) -> bool:
	var level_index = level_number-1
	level_info[level_index]["completed"] = true
	
	var all_complete = true
	for level in level_info:
		if level["completed"] == false:
			all_complete = false
	
	return all_complete




func generate_level(number_of_rooms:int=8):
	var level_data = []
	var room_info
	var entry_direction
	var room_data
	var generate_map = true
	
	while generate_map == true:
		level_data.clear()
		for room_count in range(1, number_of_rooms+1):
			if room_count == 1:
				# first room so need to create the starting room
				room_info = generate_starting_room()
			elif room_count == number_of_rooms-1:
				# second from last room is the boss room
				room_info = generate_boss_room(entry_direction)
			elif room_count == number_of_rooms:
				# final room is treasure room
				room_info = generate_treasure_room(entry_direction)
			else:
				# all other rooms are standard rooms
				room_info = generate_standard_room(entry_direction)
			
			if room_count != number_of_rooms:
				# entry direction for next room is opposite of this room's exit
				entry_direction = opposite_direction(room_info["exit_direction"])
			
			room_data = {"id": room_count}
			room_data.merge(room_info)
			level_data.append(room_data)
			
		var level_test = test_level(level_data)
		if level_test == true:
			generate_map = false
	
	return level_data

# makes sure none of the rooms overlap each other
func test_level(level_data):
	var used_tiles_set : PoolVector2Array = []
	
	var row_start
	var col_start
	
	var previous_exit_direction
	var previous_exit_position
	var previous_room_width
	var previous_room_height
	
	for room in level_data:
		# check whether it is the first room so we can calculate the drawing offset
		if room["id"] == 1:
			# first room so can start from the origin
			row_start = 0
			col_start = 0
		else:
			# need to follow on from previous room's exit
			var room_entry_position = room["entry_position"]
			match previous_exit_direction:
				NORTH:
					col_start = col_start - room["height"]
					row_start = row_start + (previous_exit_position.x) - (room_entry_position.x)
				SOUTH:
					col_start = col_start + previous_room_height
					row_start = row_start + (previous_exit_position.x) - (room_entry_position.x)
				EAST:
					row_start = row_start + previous_room_width
					col_start = col_start - (previous_room_height) + (previous_exit_position.y) - (room_entry_position.y)
				WEST:
					row_start = row_start - room["width"]
					col_start = col_start - (previous_room_height) + (previous_exit_position.y) - (room_entry_position.y)
		
		for y in range(0, room["height"]):
			for x in range(0, room["width"]):
				var tile_coord = Vector2(row_start + x, col_start + y)
				if used_tiles_set.has(tile_coord):
					return false
				else:
					used_tiles_set.append(tile_coord)
		
		# if this isn't the last room then store the exit position
		if room["id"] != level_data.size():
			previous_exit_direction = room["exit_direction"]
			previous_exit_position = room["exit_position"]
			previous_room_width = room["width"]
			previous_room_height = room["height"]
		
	return true

func generate_starting_room():
	var room_width : int = 5
	var room_height : int = 5
	
	var room_info = populate_blank_room(room_width, room_height, true)
	var room_data = room_info["data"]
	var exit_door_position = room_info["exit_position"]
	var exit_direction = room_info["exit_direction"]
	
	return {"data": room_data, "exit_direction": exit_direction, "exit_position": exit_door_position,
				"width": room_width, "height": room_height, "room_type": "STARTING"}

func generate_standard_room(entry_direction):
	var room_type
	var room_type_num = rng.randi_range(0,1)
	var enemy_count = 0
	var room_width
	var room_height
	
	if room_type_num == 0:
		room_type = "TRAP"
		room_width = rng.randi_range(6,9)
		room_height = rng.randi_range(6,9)
	else:
		room_type = "ENEMY"
		room_width = rng.randi_range(8,10)
		room_height = rng.randi_range(8,10)
	
	# GENERATE THE BASIC ROOM
	
	
	var room_info = populate_blank_room(room_width, room_height, true, entry_direction, room_type)
	var room_data = room_info["data"]
	var exit_door_position = room_info["exit_position"]
	var exit_direction = room_info["exit_direction"]
	var entry_door_position = room_info["entry_position"]
	
	if room_type == "TRAP":
		var trap_type = rng.randi_range(0,1)
		match trap_type:
			0: # spike_trap
				room_data = add_spikes(room_data, room_width, room_height, entry_direction)
			1: # temp spikes for test
				room_data = add_spikes(room_data, room_width, room_height, entry_direction)
	
	elif room_type == "ENEMY":
		var map_open_area = room_width * room_height
		if map_open_area < 75:
			enemy_count = rng.randi_range(2,3)
		else:
			enemy_count = rng.randi_range(3,4)
	
	return {"data": room_data, "entry_direction": entry_direction, "entry_position": entry_door_position,
				"exit_direction": exit_direction, "exit_position": exit_door_position, "width": room_width,
					"height": room_height, "room_type": room_type, "enemy_count": enemy_count}

func generate_boss_room(entry_direction):
	# GENERATE THE BASIC ROOM
	var room_width = 12
	var room_height = 12
	
	var room_info = populate_blank_room(room_width, room_height)	
	var room_data = room_info["data"]
	
	# GENERATE DOOR POSITIONS AND ADD THEM TO THE ROOM
	var entry_door_position : Vector2
	var exit_door_position : Vector2
	
	# if the door is on the west or east side then it's position will be along the y axis (height),
	# otherwise it's along the x (width)
	if entry_direction == WEST or entry_direction == EAST:
		entry_door_position.y = rng.randi_range(2,room_height-3)
		if entry_direction == WEST:
			entry_door_position.x = 0
			room_data[entry_door_position.y][entry_door_position.x] = GameData.TileTypes.FLOOR_TILE
		else:
			entry_door_position.x = room_width-1
			room_data[entry_door_position.y][entry_door_position.x] = GameData.TileTypes.FLOOR_TILE
		
	else:
		entry_door_position.x = rng.randi_range(2,room_width-3)
		if entry_direction == NORTH:
			entry_door_position.y = 0
			room_data[entry_door_position.y][entry_door_position.x] = GameData.TileTypes.FLOOR_TILE
		else:
			entry_door_position.y = room_height-1
			room_data[entry_door_position.y][entry_door_position.x] = GameData.TileTypes.FLOOR_TILE
	
	# chose a random exit location from 0-2 (north-east), which corresponds to the directions
	# if the exit is the same side as the entry direction add 1 to get a different direction so we will
	# get west (3) if the random number is 2 and east (2) is already the entrance
	var exit_direction = rng.randi_range(0,2)
	if exit_direction == entry_direction:
		exit_direction =+ 1
		
	if exit_direction == WEST or exit_direction == EAST:
		exit_door_position.y = rng.randi_range(2,room_height-3)
		if exit_direction == WEST:
			exit_door_position.x = 0
			room_data[exit_door_position.y][exit_door_position.x] = GameData.TileTypes.BOSS_DOOR
		else:
			exit_door_position.x = room_width-1
			room_data[exit_door_position.y][exit_door_position.x] = GameData.TileTypes.BOSS_DOOR
		
	else:
		exit_door_position.x = rng.randi_range(2,room_width-3)
		if exit_direction == NORTH:
			exit_door_position.y = 0
			room_data[exit_door_position.y][exit_door_position.x] = GameData.TileTypes.BOSS_DOOR
		else:
			exit_door_position.y = room_height-1
			room_data[exit_door_position.y][exit_door_position.x] = GameData.TileTypes.BOSS_DOOR
	
	return {"data": room_data, "entry_direction": entry_direction, "entry_position": entry_door_position,
				"exit_direction": exit_direction, "exit_position": exit_door_position, "width": room_width,
					"height": room_height, "room_type": "BOSS"}

func generate_treasure_room(entry_direction):
	# GENERATE THE BASIC ROOM
	var room_width = 5
	var room_height = 5
	var entry_position : Vector2
	
	var room_info = populate_blank_room(room_width, room_height)
	var room_data = room_info["data"]
	
	# put in the door - it's simply just in the middle of the respective wall
	match entry_direction:
		NORTH:
			entry_position = Vector2(2,0)
			room_data[0][2] = GameData.TileTypes.FLOOR_TILE
		
		SOUTH:
			entry_position = Vector2(2,4)
			room_data[4][2] = GameData.TileTypes.FLOOR_TILE
		
		EAST:
			entry_position = Vector2(4,2)
			room_data[2][4] = GameData.TileTypes.FLOOR_TILE
		
		WEST:
			entry_position = Vector2(0,2)
			room_data[2][0] = GameData.TileTypes.FLOOR_TILE
	
	return {"data": room_data, "entry_direction": entry_direction, "entry_position": entry_position,
				"width": room_width, "height": room_height, "room_type": "TREASURE"}

func populate_blank_room(room_width, room_height, add_exit=false, entry_direction=null, room_type="STANDARD"):
	var room_data : Array
	var entry_door_position : Vector2 = Vector2(0,0)
	var exit_door_position : Vector2 = Vector2(0,0)
	var exit_direction : int = -1
	
	# fill in blank map data - standard floors surrounded by walls
	for y in range(0, room_height):
		var new_row = []
		for x in range(0, room_width):
			if x == 0 or x == room_width-1 or y == 0 or y == room_height-1:
				new_row.append(GameData.TileTypes.WALL_TILE)
			else:
				new_row.append(GameData.TileTypes.FLOOR_TILE)
		room_data.append(new_row)
	
	# if we need to generate and entrance then do so based on given direction
	if entry_direction != null:
		# if the door is on the west or east side then it's position will be along the y axis (height),
		# otherwise it's along the x (width)
		if entry_direction == WEST or entry_direction == EAST:
			entry_door_position.y = rng.randi_range(2,room_height-3)
			if entry_direction == WEST:
				entry_door_position.x = 0
				room_data[entry_door_position.y][entry_door_position.x] = GameData.TileTypes.FLOOR_TILE
			else:
				entry_door_position.x = room_width-1
				room_data[entry_door_position.y][entry_door_position.x] = GameData.TileTypes.FLOOR_TILE
			
		else:
			entry_door_position.x = rng.randi_range(2,room_width-3)
			if entry_direction == NORTH:
				entry_door_position.y = 0
				room_data[entry_door_position.y][entry_door_position.x] = GameData.TileTypes.FLOOR_TILE
			else:
				entry_door_position.y = room_height-1
				room_data[entry_door_position.y][entry_door_position.x] = GameData.TileTypes.FLOOR_TILE
	
	if add_exit:
		var exit_type = GameData.TileTypes.SAFE_FLOOR_TILE
		if room_type == "ENEMY":
			exit_type = GameData.TileTypes.ENEMY_DOOR
		# chose a random exit location from 0-2 (north-east), which corresponds to the directions
		# if the exit is the same side as the entry direction add 1 to get a different direction so we will
		# get west (3) if the random number is 2 and east (2) is already the entrance
		exit_direction = rng.randi_range(0,2)
		if exit_direction == entry_direction:
			exit_direction =+ 1
		
		# add the exit type and add a dafe tile in front of it
		if exit_direction == WEST or exit_direction == EAST:
			exit_door_position.y = rng.randi_range(2,room_height-3)
			if exit_direction == WEST:
				exit_door_position.x = 0
				room_data[exit_door_position.y][exit_door_position.x] = exit_type
				room_data[exit_door_position.y][exit_door_position.x + 1] = GameData.TileTypes.SAFE_FLOOR_TILE
			else:
				exit_door_position.x = room_width-1
				room_data[exit_door_position.y][exit_door_position.x] = exit_type
				room_data[exit_door_position.y][exit_door_position.x - 1] = GameData.TileTypes.SAFE_FLOOR_TILE
		else:
			exit_door_position.x = rng.randi_range(2,room_width-3)
			if exit_direction == NORTH:
				exit_door_position.y = 0
				room_data[exit_door_position.y][exit_door_position.x] = exit_type
				room_data[exit_door_position.y + 1][exit_door_position.x] = GameData.TileTypes.SAFE_FLOOR_TILE
			else:
				exit_door_position.y = room_height-1
				room_data[exit_door_position.y][exit_door_position.x] = exit_type
				room_data[exit_door_position.y - 1][exit_door_position.x] = GameData.TileTypes.SAFE_FLOOR_TILE
	
	return { "data": room_data, "entry_direction": entry_direction, "entry_position": entry_door_position,
				"exit_direction": exit_direction, "exit_position": exit_door_position }

func add_spikes(room_data, width, height, entrance_direction):
	var spike_count = (width-2) * (height-2) / 2 - rng.randi_range(-10,10)
	
	for _i in range(0,spike_count):
		var x = rng.randi_range(1,width-2)
		var y = rng.randi_range(1,height-2)
		
		room_data[y][x] = GameData.TileTypes.SPIKE_TILE
	
	return room_data

func add_doorways(room_data, entry_position):
	pass

func opposite_direction(direction):
	var new_direction
	
	match direction:
		NORTH:
			new_direction = SOUTH
		SOUTH:
			new_direction = NORTH
		WEST:
			new_direction = EAST
		EAST:
			new_direction = WEST
	
	return new_direction

func get_level_curse(level_number):
	return level_info[level_number-1]["curse"]
