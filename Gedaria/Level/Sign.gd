extends Area2D


export(String, "res://Level/InTheWood/In the wood.tscn",
			   "res://Level/DarkForest/Dark forest.tscn",
			   "res://Level/MerchantSquirrel.tscn",
			   "res://Level/CaveEntrance/Cave entrance.tscn",
			   "res://Level/CaveEntrance/Lil cave.tscn",
			   "res://Level/CultInCave/Mine shaft.tscn",
			   "res://Level/CaveDuel/Cave duel.tscn",
			   "res://Level/ForestClearing/Forest clearing.tscn"
) var scene


func _on_Sign_body_entered(body):
	# collision layer 1 = Player
	if body.get_collision_layer_bit(1):
		Fullscreen.find_node("PauseMenu").hide()
		Fullscreen.show_loading_screen()
		body.state_machine.travel("IDLE")
		body.is_moving = false
		Global.stop_enemy_timers()
			
		yield(get_tree().create_timer(1.0), "timeout")
		SaveLoad.save_to_file(4)
		Global.is_pausable = true
		yield(get_tree().create_timer(2.0), "timeout")
		get_tree().change_scene(scene)
