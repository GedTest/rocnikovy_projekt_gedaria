extends RigidBody2D


signal hit_by_stone
signal added_pebble(oldPebblePosition)

var can_damage = false
var vladimir = null


func _ready():
	vladimir = get_parent().find_node('Vladimir')
	var mouse = vladimir.mouse_position
	apply_central_impulse(Vector2(mouse.x - position.x, mouse.y - position.y))
	$Area2D.set_collision_mask_bit(0, true)
	$Area2D.set_collision_layer_bit(0, true)
	self.set_collision_mask_bit(0, true)
#-------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(0):
		if !"Tree" in body.name:
			emit_signal("added_pebble", position)
			queue_free()
		
	elif body.get_collision_layer_bit(4):
		connect("hit_by_stone",body,"_on_hit_by_stone")
		emit_signal("hit_by_stone")
		queue_free()
	
	elif body.get_collision_layer_bit(2):
		if "Shield" in body.name:
			connect("added_pebble", get_parent(),"_on_added_pebble")
		else:
			if can_damage:
				body.hit(vladimir.damage)
			else:
				body.hit(0)
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()
