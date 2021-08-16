extends StaticBody2D


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(7) and not("BreakableFloor" in body.name):
		self.hit(body)

func hit(stone=null):
	if stone:
		stone.queue_free()
	SaveLoad.delete_actor(self)
