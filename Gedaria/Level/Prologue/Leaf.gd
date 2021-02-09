extends RigidBody2D


var enemy = null


func _on_Area2D_body_entered(body):
	# collision_layer_bit 2 = Enemy
	if body.get_collision_layer_bit(2) and body.name == "Boss":
		$Timer.start()
		enemy = body
		enemy.is_hitted = true
		enemy.is_blocking = false
		enemy.is_moving = false
		enemy.state_machine.travel('HIT_LOOP')
		enemy.find_node("stars").emitting = true
		if enemy.is_dead:
			enemy.state_machine.travel('DEATH')
# ------------------------------------------------------------------------------

func _on_Timer_timeout():
	enemy.find_node("stars").emitting = false
	enemy.is_hitted = false
	enemy.is_blocking = true
	enemy.is_moving = true
	self.queue_free()
