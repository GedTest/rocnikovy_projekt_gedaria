extends E

class_name BOSS_Warden, "res://Enemy/BOSS_Warden/BOSS_Warden.png"

var rakePath = preload("res://Enemy/BOSS_Warden/Rake.tscn")
var Bird = preload("res://Level/Prologue/Bird.tscn").instance()

var bCanThrow = false
var bThrowing = false
var bDoOnce = true
var bCanJump = true
var bWasInAir = false
var bStop = false
var bHit = false
var bMicroHit = false

var boost = 1
var maxHealth

var ThrowTimer = null
var HitInRowTimer = null

func _ready():
	FoV = 1000
	StateMachine = $AnimationTree.get("parameters/playback")
	maxHealth = health
	bBlocking = true
	
	HitInRowTimer = get_tree().create_timer(0.0)
	ThrowTimer = get_tree().create_timer(0.0)
	yield(get_tree().create_timer(10.0),"timeout")
	$Dialog.show()
	yield(get_tree().create_timer(4.0),"timeout")
	$Dialog.queue_free()
# ------------------------------------------------------------------------------
func _process(delta):
	if !bIsDead:
		
		# DAMPING VELOCITY FROM JUMP IMPULSE
		if !bCanJump && bWasInAir:
			speed += 35
			Velocity.y += 12
		
		# if he reach ground and have 0 speed then reset the speed
		elif bCanJump && bWasInAir:
			speed = 200
			bWasInAir = false
	
		# 2ND PHASE OF BOSSFIGHT
		if health == maxHealth / 2 && bDoOnce:
			get_parent().add_child(Bird)
			Bird.position = Vector2(1920,400)
			Jump()
			bDoOnce = false
			bCanThrow = true
			
		# is he in the air or on the ground ?
		bCanJump = true if $GroundRay.is_colliding() else false
		
		# does he see the player ?
		if $HitRay.is_colliding() && $HitRay.get_collider().name == "Vladimir" || $HitRay2.is_colliding() && $HitRay2.get_collider().name == "Vladimir":
			Player = $HitRay.get_collider() if $HitRay.get_collider() != null else $HitRay2.get_collider()
			bPlayer = true
		else:
			Player = null
			bPlayer = false
		
		if health > maxHealth / 2:
		# When he got 2 hits in row he is vulnerable to take damage
			if hitInRow == 2:
				bBlocking = false
				if HitInRowTimer.time_left <= 0.0:
					HitInRowTimer = get_tree().create_timer(0.75)
					yield(HitInRowTimer,"timeout")
					hitInRow = 0
				
			elif hitInRow > 0 && hitInRow < 2:
				bBlocking = true
				if HitInRowTimer.time_left <= 0.0:
					HitInRowTimer = get_tree().create_timer(2.75)
					yield(HitInRowTimer,"timeout")
					hitInRow = 0
		# If there weren't 2 hits in a row, he is in blocking state
			elif hitInRow != 2 && bAttacking:
				bBlocking = true
		elif !bHit:
			bBlocking = true
			
		Velocity = move_and_slide(Velocity)
# ------------------------------------------------------------------------------
func Move_children(): # HANDLE MOVEMENT
	if !bIsDead:
		$AnimationTree.set("parameters/JUMP/blend_position",direction)
		
		if bPlayer && !Player.bIsDead:
			#distance = abs(position.x - Player.position.x)
			if distance <= 135 && !bAttacking && !(bCanThrow || bThrowing):
				Attack()
				
			if health <= maxHealth / 2:
				if distance < 350 && bCanThrow:
					Jump()
					
				if distance > 350 && distance < 700 && bCanThrow:
					Throw()
			else:
				Dash()
		
		# MOVE FROM 'A' TO 'B'
		if !bPlayer && !bStop:
			if position.x > to:
				direction = -1
				$Sprite.flip_h = false
				$HitRay.cast_to.x = -FoV
				$HitRay2.cast_to.x = -FoV
			
			elif position.x < from:
				direction = 1
				$Sprite.flip_h = true
				$HitRay.cast_to.x = FoV
				$HitRay2.cast_to.x = FoV
		
		Velocity.x = speed * direction * boost
# ------------------------------------------------------------------------------		
func Attack(): # PRIMARY ATTACK - THRESH
	speed = 0 # Stop moving
	bStop = true # Stop moving
	$AnimationTree.set("parameters/ATTACK/blend_position",direction)
	StateMachine.travel('ATTACK')
	
	if !Player.bIsDead:
		if Player && bPlayer && bCanAttack:
			bAttacking = true
			if !Player.bBlocking:
				Player.Hit(damage)
				print("Vladimir's health: ", Player.health)
			
		if AttackTimer.time_left <= 0.0:
			AttackTimer = get_tree().create_timer(1.2)
			yield(AttackTimer, "timeout")
			bAttacking = false
			bStop = false
			speed = 200
# ------------------------------------------------------------------------------
func Dash(): # SPEEDS UP AND DASHes TOWARD THE PLAYER
	if !bAttacking:
		if distance > 450:
			boost = 2
		else:
			boost = 1
# ------------------------------------------------------------------------------
func Jump(): # JUMP IN DISTANCE SO HE CAN THROW
	# ensure the he can't jump out of screen
	if position.x > from -200 && position.x < to +200:
		bStop = true
		speed = 200
		
		speed -= 900
		Velocity.y = -1200
		yield(get_tree().create_timer(0.5),"timeout")
		bWasInAir = true
		if bCanJump:
			bStop = false
# ------------------------------------------------------------------------------
func Throw(): # SECONDARY ATTACK - THROW
	bCanThrow = false
	bThrowing = true
	bStop = true
	speed = 0
	
	$AnimationTree.set("parameters/THROW_CATCH/blend_position",direction)
	StateMachine.travel('THROW_CATCH')
	if ThrowTimer.time_left <= 0.0:
		ThrowTimer = get_tree().create_timer(0.6)
		yield(ThrowTimer, "timeout")
	
	# deal the damage by projektil
	ThrowTimer.time_left = 0.0
	add_child(rakePath.instance())
	
	StateMachine.travel('THROW_WAIT')
	if ThrowTimer.time_left <= 0.0:
		ThrowTimer = get_tree().create_timer(3.3)
		yield(ThrowTimer, "timeout")
		if !bIsDead:
			StateMachine.travel('THROW_CATCH')
		bCanThrow = true
		bThrowing = false
		bStop = false
		speed = 200
# ------------------------------------------------------------------------------
