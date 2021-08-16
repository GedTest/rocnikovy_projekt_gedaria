extends Area2D


export (Vector2) var impulse = Vector2(1250,-1600)


func _on_Wind_body_entered(body):
	if body.get_collision_layer_bit(3) and not body.is_in_group("DoNotBlow"):
		body.linear_velocity = Vector2.ZERO
		body.linear_damp = 0.25
		body.apply_central_impulse(impulse)
# ------------------------------------------------------------------------------

func disable_wind():
	for child in self.get_children():
		if "CollisionShape2D" in child.name:
			$CollisionShape2D.disabled = true
			self.hide()
