extends Area2D


export(int) var impulse = 7000
export(bool) var is_forwarding_horizontal = false
export(bool) var is_forwarding_vertical = false

var count = 0
var forward_dir = 1


func _on_Gateway_body_entered(body):
	if "RollingTree" in body.name:
		count += 1
		
		if is_forwarding_horizontal:
			forward_dir = 1 if count % 2 == 0 else -1
			body.apply_central_impulse(Vector2(impulse * forward_dir, 0))
		
		elif is_forwarding_vertical:
			forward_dir = -1 if count % 4 == 0 else 1
			if forward_dir == -1:
				body.find_node("CollisionShape2D").set_deferred("disabled", true)
				body.set_deferred("mode", RigidBody2D.MODE_STATIC)
				yield(get_tree().create_timer(0.2, false), "timeout")
				body.set_deferred("mode", RigidBody2D.MODE_RIGID)
				yield(get_tree().create_timer(1.0, false), "timeout")
				body.find_node("CollisionShape2D").set_deferred("disabled", false)
		else:
			body.apply_central_impulse(Vector2(impulse, 0))
