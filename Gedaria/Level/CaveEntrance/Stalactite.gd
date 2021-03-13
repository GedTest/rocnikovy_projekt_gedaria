extends Sprite


var damage = 1


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.hit(damage)
