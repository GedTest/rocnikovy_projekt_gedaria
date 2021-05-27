extends Node2D


var is_swinging = false
var old_parent = null

var vladimir = null
var is_yield_paused = true


func _process(delta):
	if is_swinging:
		if Input.is_action_pressed("right"):
			$RigidBody2D.apply_central_impulse(Vector2(500, -30))
		elif Input.is_action_pressed("left"):
			$RigidBody2D.apply_central_impulse(Vector2(-500, -30))
		if Input.is_action_just_pressed("jump"):
			is_swinging = false
			reparent(vladimir, old_parent)
			vladimir.set_physics_process(true)
			vladimir.position = $RigidBody2D.global_position
			$Area2D/CollisionShape2D.set_deferred("disabled", false)
		
	$Line2D.points[1] = $RigidBody2D.position
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		if !is_swinging:
			is_swinging = true
			$Area2D/CollisionShape2D.set_deferred("disabled", true)
			vladimir = body
			vladimir.position = Vector2.ZERO
			reparent(vladimir, $RigidBody2D)
			self.set_process(true)
			body.set_physics_process(false)
# ------------------------------------------------------------------------------

func reparent(child, new_parent):
	old_parent = child.get_parent()
	old_parent.call_deferred("remove_child", child)
	new_parent.call_deferred("add_child", child)
