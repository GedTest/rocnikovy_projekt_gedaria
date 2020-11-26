extends RigidBody2D

signal HitByStone
signal AddPebble(oldPebblePosition)

var bCanDamage = false
var vladimir = null

func _ready():
	vladimir = get_parent().find_node('Vladimir')
	var mouse = vladimir.mousePosition
	apply_central_impulse(Vector2(mouse.x - position.x, mouse.y - position.y))
	$Area2D.set_collision_mask_bit(0,true)
	$Area2D.set_collision_layer_bit(0,true)
	self.set_collision_mask_bit(0,true)
#-------------------------------------------------------------------------------
func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(0):
		if !"Tree" in body.name:
			emit_signal("AddPebble",position)
			queue_free()
		
	elif body.get_collision_layer_bit(4):
		connect("HitByStone",body,"OnHitByStone")
		emit_signal("HitByStone")
		queue_free()
	
	elif body.get_collision_layer_bit(2):
		if "Shield" in body.name:
			connect("AddPebble",get_parent(),"AddPebble")
		else:
			if bCanDamage:
				body.Hit(vladimir.damage)
			else:
				body.Hit(0)
# ------------------------------------------------------------------------------
# warning-ignore:unused_argument
func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()
