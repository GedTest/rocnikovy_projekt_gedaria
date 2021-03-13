extends StaticBody2D


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(7):
		body.queue_free()
		SaveLoad.delete_actor(self)
