extends RigidBody2D


const PebblePath = preload("res://Vladimir/PebbleOnGround.tscn")

var damage = 2
var pebble = null


func _ready():
	randomize()
	$Sprite.frame = randi()%3
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1) or body.get_collision_layer_bit(2):
		body.hit(damage)
		$Timer.stop()
		self.queue_free()
		
	elif body.get_collision_layer_bit(0):
		if randi() % 2 == 0:
			pebble = PebblePath.instance()
			pebble.position = self.position
			get_parent().call_deferred("add_child", pebble)
			$Timer.start()
			
		self.hide()
# ------------------------------------------------------------------------------

func _on_Timer_timeout():
	for node in get_parent().get_children():
		if "Pebble" in node.name:
			SaveLoad.delete_actor(node)
			self.queue_free()
			break
