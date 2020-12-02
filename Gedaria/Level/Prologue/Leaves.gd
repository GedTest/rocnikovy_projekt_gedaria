extends RigidBody2D


var enemy = null


func _on_Area2D_body_entered(body):
	# collision_layer_bit 2 = Enemy
	if body.get_collision_layer_bit(2) and body.name == "BOSS_Warden":
		$Timer.start()
		enemy = body
		enemy.is_hitted = true
		enemy.is_blocking = false
		enemy.speed = 0
		enemy.state_machine.travel('HIT_LOOP')
		#if enemy.is_dead:
		#	enemy.state_machine.travel('DEATH')
# ------------------------------------------------------------------------------

func _on_Timer_timeout():
	enemy.is_hitted = false
	enemy.is_blocking = true
	enemy.speed = 160
	queue_free()
