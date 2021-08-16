extends Area2D


func _on_Slingshot_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.has_slingshot = true
		SaveLoad.delete_actor(self)
