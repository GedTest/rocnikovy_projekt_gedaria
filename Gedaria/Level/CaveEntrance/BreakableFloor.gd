extends StaticBody2D


var is_heavy_attacked = false
var direction = 0


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(7):
		body.queue_free()
		SaveLoad.delete_actor(self)

func hit(damage):
	print("yay, h_a: ",is_heavy_attacked)
	if is_heavy_attacked:
		yield(get_tree().create_timer(1.0), "timeout")
		SaveLoad.delete_actor(self)
