extends Area2D


export(String, "res://Level/TestLevel.tscn",
			   "res://Level/DarkForest/DarkForest.tscn",
			   "res://Level/MerchantSquirrel.tscn",
			   "res://Level/CaveEntrance/CaveEntrance.tscn",
			   "res://Level/CaveEntrance/LiLCave.tscn",
			   "res://Level/CultInCave/CultInCave.tscn"
) var scene


func _on_Sign_body_entered(body):
	# collision layer 1 = Player
	if body.get_collision_layer_bit(1):
		Global.stop_enemy_timers()
			
		yield(get_tree().create_timer(1.0), "timeout")
		SaveLoad.save_to_file(4)
		yield(get_tree().create_timer(2.0), "timeout")
		get_tree().change_scene(scene)
