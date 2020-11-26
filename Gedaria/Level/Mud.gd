extends Area2D
export (float) var force = 0.5
export (float) var speed = 0.65

func _on_Mud_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.jumpStrength *= force
		body.modifySpeed *= speed


func _on_Mud_body_exited(body):
	if body.get_collision_layer_bit(1):
		#yield(get_tree().create_timer(0.35),"timeout")
		body.jumpStrength /= force
		body.modifySpeed /= speed
