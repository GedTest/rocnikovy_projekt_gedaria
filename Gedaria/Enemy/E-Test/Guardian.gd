extends E

var TurnAroundTimer = null
var JumpTimer = null

var bCanJump = false
var bCanMove = true

export (bool) var bJumping = true
export (int) var dir
export (int) var startingPosition
export (int) var heightLevel

func _ready():
	DeathAnimTime = 3.0
	$HitRay.cast_to.x *= dir
	bBlocking = true
	TurnAroundTimer = get_tree().create_timer(0.0,false)
	JumpTimer = get_tree().create_timer(0.0,false)
	direction = 0
# ------------------------------------------------------------------------------
# warning-ignore:unused_argument
func _physics_process(delta):
	if !bIsDead:
		if bPlayer && distance <= 150 && !bBlocking:
			if CooldownTimer.time_left <= 0.0:
				CooldownTimer = get_tree().create_timer(1.0,false)
				if !bYieldStop:
					yield(CooldownTimer,"timeout")
					Attack()
	
		# BLOCKING DAMAGE; ONLY HEAVY ATTACKS CAN BREAK BLOCKING
		if bHeavyAttack:
			$Shield.hide()
			$Shield/CollisionShape2D.disabled = true
			bBlocking = false
	else:
		$Shield.hide()
		$Shield/CollisionShape2D.disabled = true
		bBlocking = false
# ------------------------------------------------------------------------------
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func Move(): # MOVE
	if !bIsDead:
		
		# IF THERE ISN'T PLAYER GUARD POSITION
		if !bPlayer:
			# HE LOST PLAYER FROM SIGH, HE GOES TO THE GUARD POSITION
			if int(position.x) > startingPosition:
				direction = -1
				StateMachine.travel('run')
			elif int(position.x) < startingPosition:
				direction = 1
				StateMachine.travel('run')
			else:
				StateMachine.travel('standing')
				speed = 0
				
			 # IF HE FALLS OFF THE PLATFORM, HE JUMPS BACK
			if int(position.y) != heightLevel && bJumping:
				Jump()
			else:
				bCanJump = true
				
		# FOLLOW PLAYER OR NOT
		if bPlayer:
			bCanMove = true if distance > 125 else false
			bCanJump = bCanMove
			# MOVE TOWARDS PLAYER (RIGHT)
			if Player.position.x <= position.x+FoV && Player.position.x > position.x:
				if !bCanAttack:
					speed = movementSpeed
					direction = 1
					$Shield.position.x = 75
					$Sprite.flip_h = true
					$HitRay.cast_to.x = FoV
					$BackwardRay.cast_to.x = -110
			
			# MOVE TOWARDS PLAYER (LEFT)
			elif Player.position.x >= position.x-FoV && Player.position.x < position.x:
				if !bCanAttack:
					speed = movementSpeed
					direction = -1
					$Shield.position.x = -75
					$Sprite.flip_h = false
					$HitRay.cast_to.x = -FoV
					$BackwardRay.cast_to.x = 110
					
			# IF RUNNING FOR TOO MUCH LONG GO BACKWARDS
			if position.x < startingPosition || position.x > startingPosition:
				if TurnAroundTimer.time_left <= 0.0:
					TurnAroundTimer = get_tree().create_timer(6.0,false)
					if !bYieldStop:
						yield(TurnAroundTimer,"timeout")
		
		Velocity.x = speed * direction * int(bCanMove)
# ------------------------------------------------------------------------------
func Jump(): # JUMP BACK ONTO PLATFORM
	if JumpTimer.time_left <= 0.0:
		if bCanJump:
			JumpTimer = get_tree().create_timer(2.5,false)
			if !bYieldStop:
				yield(JumpTimer,"timeout")
				if !bPlayer:
					bCanJump = false
					Velocity.y -= (position.y + heightLevel) / 1.5
# ------------------------------------------------------------------------------
func Hit(dmg):
	if !bBlocking:
		# CALLING THE "BASE FUNTCION" FIRST
		.Hit(dmg)
	
	
	var knockbackDistance = 0
	# KNOCKBACK WHILE BLOCKING
	if bBlocking && int(position.x) != startingPosition:
		if $BackwardRay.is_colliding() || $BackwardRay2.is_colliding():
			var ray = $BackwardRay if $BackwardRay.is_colliding() else $BackwardRay2
			knockbackDistance = abs(position.x - ray.get_collision_point().x)
		position.x -= (100 - knockbackDistance) * direction
# ------------------------------------------------------------------------------
func Attack(): # DO ATTACK
	if !bIsDead:
		bCanMove = false
		$AnimationTree.set("parameters/ATTACK/blend_position",direction)
		StateMachine.travel('ATTACK')
		
		if bPlayer:
			if !Player.bIsDead && bCanAttack && !bAttacking:
				bAttacking = true
				if !Player.bBlocking:
					Player.Hit(damage)
					print("Vladimir's health: ", Player.health)
					
		if AttackTimer.time_left <= 0.0:
			AttackTimer = get_tree().create_timer(1.2,false)
			if !bYieldStop:
				yield(AttackTimer, "timeout")
				speed = movementSpeed
				bAttacking = false
				bCanMove = true
