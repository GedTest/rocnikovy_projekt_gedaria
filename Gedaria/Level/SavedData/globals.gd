extends Node


var blue_berries = 0
var last_map = ""
var arr_levels = [
	"res://Level/TestLevel.tscn","res://Level/DarkForest/DarkForest.tscn",
	"ahoj_level"
]
var next_level_id = arr_levels.find(last_map) - 1
var prev_level_id = arr_levels.find(last_map) + 1
# Vladimir's variables

var is_pausable = false
var is_yield_paused = false


func level_root():
	for root in get_tree().get_nodes_in_group("root"):
		return root
# ------------------------------------------------------------------------------

func get_position_2D(ID):
	print("ID: ",ID)
	for x in get_tree().get_nodes_in_group("pos"):
		if x.name == ID:
			return x
# ------------------------------------------------------------------------------

func delete_actor(relate):
	SaveLoad.current_data.erase(str([level_root().filename, relate.name]))
	relate.queue_free()
# ------------------------------------------------------------------------------

func vladimir_data():
	return "["+arr_levels[prev_level_id]+", Vladimir]"
# ------------------------------------------------------------------------------

func get_level_by_index(index):
	return arr_levels[next_level_id]
# ------------------------------------------------------------------------------

func vladimir_has_previous_data():
	return SaveLoad.slots["slot_4"].has(vladimir_data())
# ------------------------------------------------------------------------------
#func Persistant():
#	return level_root().get_node("Persistant")
#func teleport_actor(relate, map, pos_ID):
#	if SaveLoad.current_data.has([level_root().filename, relate.name]):
#		var old = (SaveLoad.current_data[[level_root().filename, relate.name]]).duplicate()
#		SaveLoad.current_data[[map, relate.name]] = old
#		SaveLoad.current_data[[map, relate.name]]["next_pos_ID"] = pos_ID
#		SaveLoad.current_data.erase([level_root().filename, relate.name])
#		relate.queue_free()
# ------------------------------------------------------------------------------
#
#func player():
#	for x in get_tree().get_nodes_in_group("player"):
#		return x
# ------------------------------------------------------------------------------

#func change_level(map, pos_ID):
#	teleport_actor(player(), map, pos_ID)
#	yield(get_tree().create_timer(0.1), "timeout")
#	get_tree().change_scene(map)
