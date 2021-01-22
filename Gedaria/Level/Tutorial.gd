extends Area2D

export(String, "throwing",
				"raking_out_leaves",
				"hiding",
				"heavy_attack",
				"shooting",
				"raking",
				"wind"
)var text


func _on_Tutorial_body_entered(body):
	if body.get_collision_layer_bit(1):
		$TextSprite/Label.text = Global.language["czech"][text]
		$TextSprite.show()
# ------------------------------------------------------------------------------

func _on_Tutorial_body_exited(body):
	if body.get_collision_layer_bit(1):
		$TextSprite.hide()
