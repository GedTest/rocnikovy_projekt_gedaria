extends Area2D


const StonePath = preload("res://Level/CaveEntrance/Stone.tscn")


func _on_FallingStonesSpawner_body_entered(body):
	if body.get_collision_layer_bit(1):
		
		var stone = StonePath.instance()
			
		stone.position = Vector2(self.position.x, self.position.y + 60)
		get_parent().call_deferred("add_child", stone)
