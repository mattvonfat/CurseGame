extends Node

enum Curses { HEALTH_DEGEN=0, REDUCED_SPEED, SLOWER_SHOOTING, MISS_CHANCE, ENEMY_DAMAGE }

enum TileTypes { WALL_TILE=0, FLOOR_TILE, SAFE_FLOOR_TILE, SPIKE_TILE, BOSS_DOOR, ENEMY_DOOR }

onready var temple_names = [ "Temple of Death", "Temple of the Sun", "Zincarrs Resting Place", "Tomb of the One King",
"Tomb of the Unnerved" ]

onready var treasure_list = [
	{ "image": preload("res://images/treasures/jewel.png") },
	{ "image": preload("res://images/treasures/crown.png") },
	{ "image": preload("res://images/treasures/skull.png") },
	{ "image": preload("res://images/treasures/book.png") }
]

onready var curse_data = {
	Curses.HEALTH_DEGEN: { "name": "Vampiric Mark", "description": "A vampiric curse gradually drains the victim's lifeforce until they become a withered husk.", "tooltip": "Losing 1 health per second." },
	Curses.REDUCED_SPEED: { "name": "Crippling Burden", "description": "The victim is burdened by an illusionary weight, causing them to move slower.", "tooltip": "Movement speed reduced." },
	Curses.SLOWER_SHOOTING: { "name": "Slower Shooting", "description": "Shooting speed is reduced.", "tooltip": "Shooting rate is reduced." },
	Curses.MISS_CHANCE: { "name": "Miss Chance", "description": "Chance that enemies aren't hit when shot.", "tooltip": "Have a chance to miss shots." },
	Curses.ENEMY_DAMAGE: { "name": "Curse of Weakness", "description": "The victim becomes frail, increasing the damage recived by enemies", "tooltip": "Taking increased damage from enemies." }
}

func get_curse_name(curse_id):
	return curse_data[curse_id]["name"]

func get_curse_description(curse_id):
	return curse_data[curse_id]["description"]

func get_treasure_icon(treasure_id):
	return treasure_list[treasure_id]["image"]
