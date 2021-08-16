class_name MushroomSpring, "res://Level/Mushroom_spring0.png"
extends Area2D


export(int) var const_value = 2750
export(float) var modifier = 1.25


func _on_MushroomSpring_body_entered(body):
	if body.get_collision_layer_bit(1):
		if $LeftRay.is_colliding() or $MiddleRay.is_colliding()\
		 or $RightRay.is_colliding():
			$AnimatedSprite.frame = 0
			$AnimatedSprite.play("bounce")
			var jumped_height = body.jumped_height.y
			var height = const_value+((position.y - jumped_height) * modifier)
			body.velocity.y = -height
