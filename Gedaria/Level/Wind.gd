extends Area2D


export (Vector2) var impulse = Vector2(1250, -1600)
export (bool) var is_leaf_blower = false
export (bool) var can_blow_player = false


func _on_Wind_body_entered(body):
	if body is LeafHolder:
		return
	
	if body.get_collision_layer_bit(3) or (body.get_collision_layer_bit(10) and is_leaf_blower):
		body.linear_velocity = Vector2.ZERO
		body.linear_damp = 0.25
		impulse *= 3 if body is PileOfLeaves else 1
		body.apply_central_impulse(impulse)
	
	if body.get_collision_layer_bit(2) and is_leaf_blower:
		var root = Global.level_root()
		var direction = root.find_node("Vladimir").position.direction_to(body.position)
		direction = 1 if direction.x > 0 else -1
		body.jump_back(body, 100, 0.3, direction)
	
	if can_blow_player and body.get_collision_layer_bit(1):
		body.jump_strength *= impulse.y
		body.modify_speed *= impulse.x
# ------------------------------------------------------------------------------

func disable_wind():
	for child in self.get_children():
		if "CollisionShape2D" in child.name:
			$CollisionShape2D.disabled = true
			self.hide()
# ------------------------------------------------------------------------------

func _on_WindBlowerWind_body_exited(body):
	if can_blow_player and body.get_collision_layer_bit(1):
		body.jump_strength /= impulse.y
		body.modify_speed /= impulse.x
