extends Area2D


const StonePath = preload("res://Level/Cave_entrance/Stone.tscn")


func _on_FallingStonesSpawner_body_entered(body):
	if body.get_collision_layer_bit(1):
		
		var stone = StonePath.instance()
			
		stone.position = self.position
		get_parent().call_deferred("add_child", stone)
