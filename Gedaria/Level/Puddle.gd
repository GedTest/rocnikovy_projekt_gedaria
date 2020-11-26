extends Area2D
export (float) var force = 2

func _on_PuddleMud_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.modifySpeed *= force

func _on_Puddle_body_exited(body):
	if body.get_collision_layer_bit(1):
		body.modifySpeed /= force
