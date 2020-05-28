extends Area2D

export(String, "res://Level/TestLevel.tscn","res://Level/World2.tscn") var Scene

func _on_Sign_body_entered(body):
	if body.get_collision_layer_bit(1):
		Save_Load.checkpoint = null
		# change level
		get_tree().change_scene(Scene)
