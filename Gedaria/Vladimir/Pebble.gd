extends RigidBody2D


signal hit_by_stone

var PebblePath = preload("res://Vladimir/PebbleOnGround.tscn")

var can_damage = false
var vladimir = null
var has_hitted_shield = false


func _ready():
	vladimir = get_parent().find_node('Vladimir')
	var mouse = vladimir.mouse_position
	apply_central_impulse(Vector2(mouse.x - position.x, mouse.y - position.y))
	$Area2D.set_collision_mask_bit(0, true)
	$Area2D.set_collision_layer_bit(0, true)
	self.set_collision_mask_bit(0, true)
#-------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if "Shield" in body.name:
		has_hitted_shield = true
			
	if body.get_collision_layer_bit(0):
		if !"Tree" in body.name:
			if has_hitted_shield:
				add_pebble(position)
			queue_free()
		
	elif body.get_collision_layer_bit(4):
		connect("hit_by_stone",body,"_on_hit_by_stone")
		emit_signal("hit_by_stone")
		queue_free()
	
	elif body.get_collision_layer_bit(2):
		if "Guardian" in body.name:
			body.is_blocking = false
		if can_damage:
			body.hit(vladimir.damage)
		else:
			body.hit(0)
			
	if "Guardian" in body.name:
		body.is_blocking = true
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()
# ------------------------------------------------------------------------------

func add_pebble(old_pebble_position):
	var pebble = PebblePath.instance()
	Global.level_root().call_deferred("add_child", pebble)
	pebble.position = old_pebble_position
