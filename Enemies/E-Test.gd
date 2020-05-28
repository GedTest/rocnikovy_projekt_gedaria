extends E

# ------------------------------------------------------------------------------
# warning-ignore:unused_argument
func _physics_process(delta):
	if !bIsDead:
		print($CollisionShape2D.scale.x)
		#print($AnimatedSprite/WeaponHitbox/CollisionShape2D.disabled) # OK
		#print($AnimatedSprite/WeaponHitbox.position.x)
		#print(Player, " bPlayer: ", bPlayer)                          # OK
		#print("bCanAttack: ",bCanAttack)                              # OK
		if bCanAttack:
			Attack()
# ------------------------------------------------------------------------------
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func Move_children(var from, var to): # MOVE
	if !bIsDead:
		print(name, bOnGround)
		bOnGround = true if $GroundRay.is_colliding() else false
		if !bOnGround:
			print(name," is not on ground")
			position.x = (to + from) / 2
		if !bCanAttack:
			$AnimatedSprite.play("run")
	# MOVE FROM 'A' TO 'B'
		if !bPlayer:
			if position.x > to:
				direction = -1
				Turn(true)
				$HitRay.cast_to.x = -FoV
		
			elif position.x < from:
				direction = 1
				Turn(false)
				$HitRay.cast_to.x = FoV
	# FOLLOW PLAYER OR NOT
		if bPlayer:
			if Player.position.x <= position.x+FoV && Player.position.x > position.x:
			# MOVE TOWARDS PLAYER (RIGHT)
				if !bCanAttack:
					direction = 1
		#			Turn(true)
					$HitRay.cast_to.x = FoV
			# WALKING BACKWARDS
				else:
					yield(get_tree().create_timer(2.5),"timeout")
					direction = -1
					$HitRay.enabled = false
		
			elif Player.position.x >= position.x-FoV && Player.position.x < position.x:
				# MOVE TOWARDS PLAYER (LEFT)
				if !bCanAttack:
					direction = -1
		#			Turn(false)
					$HitRay.cast_to.x = -FoV
				# WALKING BACKWARDS
				else:
					yield(get_tree().create_timer(2.5),"timeout")
					direction = 1
					$HitRay.enabled = false
			
			yield(get_tree().create_timer(1),"timeout")
			$HitRay.enabled = true
			
		Velocity.x = speed * direction
# ------------------------------------------------------------------------------
func Attack(): # DO ATTACK
	Velocity.x = 0
	$AnimatedSprite.play("attack")
	# if it can attack and Player is within a range
	if bAttacking && Player && bPlayer:
		bAttacking = false
		Player.health -= damage
		print("Vladimir's health: ", Player.health)
# ------------------------------------------------------------------------------
func on_AttackTimeout(): # SET COOLDOWN
	bAttacking = true
	AttackTimer.start()
# ------------------------------------------------------------------------------
