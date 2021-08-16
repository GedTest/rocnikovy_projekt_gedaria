extends RigidBody2D


var PebblePath = preload("res://Vladimir/PebbleOnGround.tscn")

var can_damage = false
var vladimir = null
var has_hitted_shield = false


func _ready():
	vladimir = get_parent().find_node('Vladimir')
	var mouse = vladimir.mouse_position
	self.apply_central_impulse(Vector2(mouse.x - position.x, mouse.y - position.y)*1.5)
#-------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if "Shield" in body.name:
		has_hitted_shield = true
			
	if body.get_collision_layer_bit(0):
		# body = terrain
		if not "Tree" in body.name:
			if has_hitted_shield:
				add_pebble(position)
			queue_free()
	
	elif body.get_collision_layer_bit(2):
		# body = enemy
		if "Guardian" in body.name:
			body.is_blocking = false
			# Guardian has shield that block pebbles
			# but you can hit him from behind
		if can_damage:
			body.hit(vladimir.damage)
			if "Guardian" in body.name:
				body.is_blocking = true
		else:
			body.hit(0)
# ------------------------------------------------------------------------------

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	# pebble free itself when is beyond screen
	queue_free()
# ------------------------------------------------------------------------------

func add_pebble(old_pebble_position):
	var pebble = PebblePath.instance()
	Global.level_root().call_deferred("add_child", pebble)
	pebble.position = old_pebble_position
