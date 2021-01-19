extends Area2D


export(String, "res://Level/TestLevel.tscn",
			   "res://Level/DarkForest/DarkForest.tscn",
			   "res://Level/MerchantSquirrel.tscn"
) var scene


func _on_Sign_body_entered(body):
	# collision layer 1 = Player
	if body.get_collision_layer_bit(1):
		#get_tree().set_pause(true)
		#SaveLoad.update_current_data()
		SaveLoad.save_to_file(4)
		get_tree().change_scene(scene)