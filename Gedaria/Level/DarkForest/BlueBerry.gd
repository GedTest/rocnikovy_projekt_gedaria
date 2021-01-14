extends Sprite


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		Global.blue_berries += 1
		SaveLoad.delete_actor(self)
