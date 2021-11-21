extends RigidBody2D


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(4) or body.get_collision_layer_bit(1):
		$AnimationPlayer.play("ACTIVATE")
		$Area2D/CollisionShape2D.set_deferred("disabled", true)
		$Timer.start()
		
		if body is Vladimir:
			body.hit(1)
# ------------------------------------------------------------------------------

func _on_Timer_timeout():
	self.call_deferred("queue_free")
