extends E

var TurnAroundTimer = null
var JumpTimer = null
var DoABarrelRollTimer = null

var bWasPlayer = false
var bCanJump = false
var bReverse = false
export (int) var heightLevel

func _ready():
	TurnAroundTimer = get_tree().create_timer(0.0)
	JumpTimer = get_tree().create_timer(0.0)
	DoABarrelRollTimer = get_tree().create_timer(0.0)
# ------------------------------------------------------------------------------
# warning-ignore:unused_argument
func _physics_process(delta):
	if !bIsDead:
		bReverse = true if direction == -1 else false
		
		if bPlayer && distance <= 135:
			Attack()
		
		# DO A BARREL ROLL
		elif bWasPlayer && !bAttacking && distance <= 300:
			position.x += 10 * direction
			$HitRay.enabled = false
		
			if DoABarrelRollTimer.time_left <= 0.0:
				DoABarrelRollTimer = get_tree().create_timer(0.4)
				yield(DoABarrelRollTimer,"timeout")
				$HitRay.enabled = true
				bWasPlayer = false
				$Sprite.flip_h = !$Sprite.flip_h 
				$HitRay.cast_to.x = -$HitRay.cast_to.x
# ------------------------------------------------------------------------------
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func Move(var from, var to): # MOVE
	if !bIsDead:
	# MOVE FROM 'A' TO 'B'
		if !bPlayer && !bWasPlayer:
			if position.x > to:
				direction = -1
				$Sprite.flip_h = false
				$HitRay.cast_to.x = -FoV
		
			elif position.x < from:
				direction = 1
				$Sprite.flip_h = true
				$HitRay.cast_to.x = FoV
			
			# LOOK AROUND FOR PLAYER
			if TurnAroundTimer.time_left <= 0.0 && !bPlayer:
				TurnAroundTimer = get_tree().create_timer(5.0)
				yield(TurnAroundTimer,"timeout")
				TurnAround()
				
			 # IF HE FALLS OFF THE PLATFORM, HE JUMPS BACK
			if int(position.y) != heightLevel:  # && bWasPlayer
				Jump()
			else:
				bCanJump = true
				
	# FOLLOW PLAYER OR NOT
		if bPlayer:
			bWasPlayer = true
			
			# MOVE TOWARDS PLAYER (RIGHT)
			if Player.position.x <= position.x+FoV && Player.position.x > position.x:
				if !bCanAttack:
					direction = 1
					$Sprite.flip_h = true
					$HitRay.cast_to.x = FoV
			
			# MOVE TOWARDS PLAYER (LEFT)
			elif Player.position.x >= position.x-FoV && Player.position.x < position.x:
				if !bCanAttack:
					direction = -1
					$Sprite.flip_h = false
					$HitRay.cast_to.x = -FoV
					
			# IF RUNNING FOR TOO MUCH LONG
			if position.x < from || position.x > to:
				if TurnAroundTimer.time_left <= 0.0:
					TurnAroundTimer = get_tree().create_timer(2.0)
					yield(TurnAroundTimer,"timeout")
					$Sprite.flip_h = !$Sprite.flip_h 
					$HitRay.cast_to.x = -$HitRay.cast_to.x 
			
		Velocity.x = speed * direction
# ------------------------------------------------------------------------------
func Attack(): # DO ATTACK
	print('attack')
	speed = 0
	Velocity.x = 0
	$AnimationTree.set("parameters/ATTACK/blend_position",direction)
	StateMachine.travel('ATTACK')
	
	if !Player.bIsDead:
		if Player && bPlayer && bCanAttack && !bAttacking:
			bAttacking = true
			if !Player.bBlocking:
				Player.Hit(damage)
				print("Vladimir's health: ", Player.health)
				
	if AttackTimer.time_left <= 0.0:
		AttackTimer = get_tree().create_timer(1.2)
		yield(AttackTimer, "timeout")
		speed = movementSpeed
		print('end of attakc')
		bAttacking = false
# ------------------------------------------------------------------------------
func TurnAround(): # LOOK BACK AND FORTH
	$Sprite.flip_h = !$Sprite.flip_h
	speed = 0
	$HitRay.cast_to.x = -$HitRay.cast_to.x
	
	if TurnAroundTimer.time_left <= 0.0:
		TurnAroundTimer = get_tree().create_timer(0.75)
		yield(TurnAroundTimer,"timeout")
		speed = movementSpeed
		if !bPlayer:
			$Sprite.flip_h = !$Sprite.flip_h
			$HitRay.cast_to.x = -$HitRay.cast_to.x
# ------------------------------------------------------------------------------
func Jump(): # JUMP BACK ONTO PLATFORM
	if JumpTimer.time_left <= 0.0:
		if bCanJump:
			JumpTimer = get_tree().create_timer(2.5)
		yield(JumpTimer,"timeout")
		bCanJump = false
		Velocity.y -= (position.y + heightLevel) * 1.95
# ------------------------------------------------------------------------------
