extends Sprite


func _on_Area_body_entered(body):
	if body.get_collision_layer_bit(1):
		$Sprite.show()
# ------------------------------------------------------------------------------

func _on_Area_body_exited(body):
	if body.get_collision_layer_bit(1):
		$Sprite.hide()
