extends StaticBody2D


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.find_node("Camera").offset.y = 300
# ------------------------------------------------------------------------------

func _on_Area2D_body_exited(body):
	if body.get_collision_layer_bit(1):
		body.find_node("Camera").offset.y = 0
