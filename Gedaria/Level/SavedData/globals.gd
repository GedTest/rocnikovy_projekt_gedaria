extends Node


var blue_berries = 0
var last_map = ""

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
#func Persistant():
#	return level_root().get_node("Persistant")
