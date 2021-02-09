extends RigidBody2D


const PebblePath = preload("res://Vladimir/PebbleOnGround.tscn")

var damage = 2


func _ready():
	pass


#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1) or body.get_collision_layer_bit(2):
		body.hit(damage)
		self.queue_free()
		
	elif body.get_collision_layer_bit(0):
		if randi() % 2 == 0:
			var pebble = PebblePath.instance()
			pebble.position = self.position
			get_parent().call_deferred("add_child", pebble)
			
		self.queue_free()
