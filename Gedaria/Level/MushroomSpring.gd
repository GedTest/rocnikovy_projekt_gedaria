extends Area2D
class_name MushroomSpring, "res://Level/Mushroom3.png"

export(int) var constValue = 2750
export(float) var modifier = 1.25

func _on_MushroomSpring_body_entered(body):
	if body.get_collision_layer_bit(1) && $RayCast2D.is_colliding():
		$AnimatedSprite.frame = 0
		$AnimatedSprite.play("bounce")
		var jumpedHeight = body.jumpedHeight.y
		var height = constValue+((position.y - jumpedHeight)*modifier)
		body.Velocity.y = -height
