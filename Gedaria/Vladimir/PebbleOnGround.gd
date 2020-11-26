extends RigidBody2D

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1) && body.pebbleCounter < 5:
		body.pebbleCounter += 1
		get_parent().get_parent().find_node("UserInterface").UpdatePebbles(1,"plus",body.pebbleCounter)
		SaveLoad.delete_actor(self)
