extends Node


var arr_levels = [
	"res://Level/InTheWood/In the wood.tscn",
	"res://Level/DarkForest/Dark forest.tscn",
	"res://Level/CaveEntrance/Cave entrance.tscn",
	"res://Level/CultInCave/Mine shaft.tscn",
	"res://Level/CaveDuel/Cave duel.tscn",
	"res://Level/ForestClearing/Forest clearing.tscn",
	"res://Level/Telpenor town/Telpenor town.tscn",
]
var current_key_mapping = []

var DEFAULT_SETTINGS = {
	"MasterVolume":0,
	"MusicVolume":0,
	"SFXVolume":0,
	"MSAA":1,
	"FPS":60,
	"VSync":true,
	"Language":"english",
	"key_mapping":[87,65,83,68,1,2,32,16777237,16777254,69,81,16777217]
}

var last_map = ""
var prefered_language = "english"

var blue_berries = 0
var leaves_in_cave_counter = 0
var has_key = false
var next_level_id = 1
var prev_level_id = 0

var is_done_once = false
var is_pausable = true
var is_yield_paused = false
var first_entrance = true
var is_boss_on_map = false


func level_root():
	for root in get_tree().get_nodes_in_group("root"):
		return root
# ------------------------------------------------------------------------------

func get_position_2D(ID):
	for x in get_tree().get_nodes_in_group("pos"):
		if x.name == ID:
			return x
# ------------------------------------------------------------------------------

func delete_actor(relate):
	SaveLoad.current_data.erase(str([level_root().filename, relate.name]))
	relate.queue_free()
# ------------------------------------------------------------------------------

func vladimir_data():
#	if last_map == "res://Level/In the wood.tscn":
#		prev_level_id = 0
#	elif last_map == "res://Level/DarkForest/Dark forest.tscn":
#		prev_level_id = 1
#	elif last_map == "res://Level/CaveEntrance/LiLCave.tscn":
#		return "[res://Level/CaveEntrance/LiLCave.tscn, Vladimir]"
#	else:
	if last_map == "res://Level/CaveEntrance/Lil cave.tscn":
		return "[res://Level/CaveEntrance/Lil cave.tscn, Vladimir]"
	else:
		prev_level_id = arr_levels.find(last_map)# - 1

		return "["+arr_levels[prev_level_id]+", Vladimir]"
# ------------------------------------------------------------------------------

func get_next_level():
	next_level_id = arr_levels.find(last_map) + 1
	return arr_levels[next_level_id]
# ------------------------------------------------------------------------------

func vladimir_has_previous_data():
	return SaveLoad.slots["slot_4"].has(vladimir_data())
# ------------------------------------------------------------------------------

func stop_enemy_timers():
	is_yield_paused = true
	if "arr_enemies" in level_root():
		
		for enemy in level_root().arr_enemies:
			if not enemy.is_dead:
				enemy.turn_around_timer.time_left = 0.0
				if "cooldown_roll_timer" in enemy:
					enemy.cooldown_roll_timer.time_left = 0.0
# ------------------------------------------------------------------------------

func set_player_position_at_start(player, start):
	if not level_root().filename in SaveLoad.visited_maps:
		player.position = start.position
# ------------------------------------------------------------------------------

func is_first_entrance(level):
	if level in SaveLoad.visited_maps:
		first_entrance = false
# ------------------------------------------------------------------------------

func update_data_from_merchant(vladimir):
	if first_entrance:
		var vladimir_data = "["+str(last_map)+", Vladimir]"
		
		if SaveLoad.slots["slot_4"].has(vladimir_data):
			vladimir.set_values(SaveLoad.slots["slot_4"][vladimir_data])
# ------------------------------------------------------------------------------

func reset_data():
	last_map = ""
	
	blue_berries = 0
	leaves_in_cave_counter = 0
	next_level_id = 1
	prev_level_id = 0
	
	is_done_once = false
	is_pausable = true
	is_yield_paused = false
	first_entrance = true
	is_boss_on_map = false
	
	SaveLoad.reset_data()
# ------------------------------------------------------------------------------
