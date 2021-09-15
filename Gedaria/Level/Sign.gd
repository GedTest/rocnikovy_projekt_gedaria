extends Area2D


export(String, "res://Level/InTheWood/In the wood.tscn",
			   "res://Level/DarkForest/Dark forest.tscn",
			   "res://Level/MerchantSquirrel.tscn",
			   "res://Level/CaveEntrance/Cave entrance.tscn",
			   "res://Level/CaveEntrance/Lil cave.tscn",
			   "res://Level/CultInCave/Mine shaft.tscn",
			   "res://Level/CaveDuel/Cave duel.tscn",
			   "res://Level/ForestClearing/Forest clearing.tscn",
			   "res://Level/Telpenor town/Telpenor town.tscn"
) var scene

var level_acorns = 0
var level_unique_leaves = 0
var level_enemies = 0
var vladimir_acorns = 0
var collected_unique_leaves = 0
var killed_enemies = 0
var played_time = 0 # in seconds


func _on_Sign_body_entered(body):
	# collision layer 1 = Player
	if body.get_collision_layer_bit(1):
		if Global.level_root().filename != "res://Level/MerchantSquirrel.tscn":
			self.set_collectibles_values()
		Fullscreen.find_node("PauseMenu").hide()
		Fullscreen.show_loading_screen()
		body.state_machine.travel("IDLE")
		body.is_moving = false
		Global.stop_enemy_timers()
			
		yield(get_tree().create_timer(1.0), "timeout")
		SaveLoad.save_to_file(4)
		Global.is_pausable = true
		yield(get_tree().create_timer(2.5), "timeout")
		get_tree().change_scene(scene)
# ------------------------------------------------------------------------------

func set_collectibles_values():
	var level = Global.level_root()
	var vladimir = level.find_node("Vladimir")
	
	level_acorns = level.acorn_counter
	level_unique_leaves = level.unique_leaves_counter
	level_enemies = level.arr_enemies.size()
	vladimir_acorns = vladimir.acorn_counter
	killed_enemies = level.arr_killed_enemies.size()
# ------------------------------------------------------------------------------

func save(): # SAVE VARIABLES IN DICTIONARY
	var saved_data = {
		"level_acorns":level_acorns,
		"level_unique_leaves":level_unique_leaves,
		"level_enemies":level_enemies,
		"vladimir_acorns":vladimir_acorns,
		"collected_unique_leaves":collected_unique_leaves,
		"killed_enemies":killed_enemies,
		"played_time":played_time
	}
	return saved_data
