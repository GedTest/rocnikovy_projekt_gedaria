extends RigidBody2D
var enemy = null
func _on_Area2D_body_entered(body):
	# collision_layer_bit 2 = Enemy
	if body.get_collision_layer_bit(2) && body.name == "BOSS_Warden":
		$Timer.start()
		enemy = body
		enemy.bHit = true
		enemy.bBlocking = false
		enemy.speed = 0
		enemy.StateMachine.travel('HIT_LOOP')
		if enemy.bIsDead:
			enemy.StateMachine.travel('DEATH')
		
func _on_Timer_timeout():
	enemy.bHit = false
	enemy.bBlocking = true
	enemy.speed = 160
	queue_free()
