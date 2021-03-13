extends RigidBody2D


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.position.y += 30
		body.die()
