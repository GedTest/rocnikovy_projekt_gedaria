extends RigidBody2D


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(4) or body.get_collision_layer_bit(1):
		$AnimationPlayer.play("ACTIVATE")
		$Area2D/CollisionShape2D.set_deferred("disabled", true)
		
		if body is Vladimir:
			body.hit(1)
