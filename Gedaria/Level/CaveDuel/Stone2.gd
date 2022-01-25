extends RigidBody2D


const PebblePath = preload("res://Vladimir/PebbleOnGround.tscn")

var damage = 1


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.hit(damage)
		self.queue_free()
		
	elif body.get_collision_layer_bit(0):
		if randi() % 4 == 0:
			var pebble = PebblePath.instance()
			pebble.position = self.position
			get_parent().call_deferred("add_child", pebble)

		self.queue_free()
