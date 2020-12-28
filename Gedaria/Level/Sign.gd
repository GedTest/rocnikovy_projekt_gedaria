extends Area2D


export(String, "res://Level/TestLevel.tscn",
			   "res://Level/DarkForest/DarkForest.tscn"
) var scene


func _on_Sign_body_entered(body):
	# collision layer 1 = Player
	if body.get_collision_layer_bit(1):
		get_tree().change_scene(scene)
