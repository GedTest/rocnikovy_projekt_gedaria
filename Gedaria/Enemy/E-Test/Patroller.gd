extends E

var TurnAroundTimer = null
var JumpTimer = null
var DoABarrelRollTimer = null
var CooldownRollTimer = null

var bWasPlayer = false
var bCanJump = false
var bReverse = false
var bCanMove = true
var bCanRoll = false

export (bool) var bCanTurnAround = true
export (bool) var bRolling = true
export (bool) var bJumping = true
export (int) var heightLevel

func _ready():
	DeathAnimTime = 3.0
	TurnAroundTimer = get_tree().create_timer(0.0,false)
	JumpTimer = get_tree().create_timer(0.0,false)
	DoABarrelRollTimer = get_tree().create_timer(0.0,false)
	CooldownRollTimer = get_tree().create_timer(0.0,false)
# ------------------------------------------------------------------------------
# warning-ignore:unused_argument
func _physics_process(delta):
	if !bIsDead:
		bReverse = true if direction == -1 else false
		
		if bPlayer && distance <= 135:
			if CooldownTimer.time_left <= 0.0:
				CooldownTimer = get_tree().create_timer(1.0,false)
				if !bYieldStop:
					yield(CooldownTimer,"timeout")
					Attack()
				
		if CooldownRollTimer.time_left <= 0.0 && !bCanAttack && bRolling:
			CooldownRollTimer = get_tree().create_timer(4.0,false)
			if !bYieldStop:
				yield(CooldownRollTimer,"timeout")
				bCanRoll = true
		
		# DO A BARREL ROLL
		if bRolling:
			if bWasPlayer && !bAttacking && distance <= 300 && bCanRoll:
				position.x += 10 * direction
				$HitRay.enabled = false
			
				if DoABarrelRollTimer.time_left <= 0.0:
					DoABarrelRollTimer = get_tree().create_timer(0.4,false)
					if !bYieldStop:
						yield(DoABarrelRollTimer,"timeout")
						$HitRay.enabled = true
						bWasPlayer = false
						$Sprite.flip_h = !$Sprite.flip_h 
						$HitRay.cast_to.x = -$HitRay.cast_to.x
						bCanRoll = false
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
				TurnAroundTimer = get_tree().create_timer(5.0,false)
				if !bYieldStop:
					yield(TurnAroundTimer,"timeout")
					TurnAround()
			
			if bJumping:
				 # IF HE FALLS OFF THE PLATFORM, HE JUMPS BACK
				if int(position.y) != heightLevel:
					Jump()
				else:
					bCanJump = true
				
	# FOLLOW PLAYER OR NOT
		if bPlayer:
			if Player.bHidden:
				bPlayer = false
				Player = null
				speed = movementSpeed
				return
				
			if bRolling:
				bWasPlayer = true
			if !bCanRoll || !bRolling:
				bCanMove = true if distance > 125 else false
				bCanJump = bCanMove
			
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
					TurnAroundTimer = get_tree().create_timer(2.0,false)
					if !bYieldStop:
						yield(TurnAroundTimer,"timeout")
						$Sprite.flip_h = !$Sprite.flip_h 
						$HitRay.cast_to.x = -$HitRay.cast_to.x 
			
		Velocity.x = speed * direction * int(bCanMove)
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
				bAttacking = false
				bCanMove = true
# ------------------------------------------------------------------------------
func TurnAround(): # LOOK BACK AND FORTH
	if !bIsDead && bCanTurnAround:
		StateMachine.travel('STANDING')
		$Sprite.flip_h = !$Sprite.flip_h
		speed = 0
		$HitRay.cast_to.x = -$HitRay.cast_to.x
		
		if TurnAroundTimer.time_left <= 0.0:
			TurnAroundTimer = get_tree().create_timer(0.75,false)
			if !bYieldStop:
				yield(TurnAroundTimer,"timeout")
				speed = movementSpeed
				if !bPlayer:
					$Sprite.flip_h = !$Sprite.flip_h
					$HitRay.cast_to.x = -$HitRay.cast_to.x
				StateMachine.travel('run')
# ------------------------------------------------------------------------------
func Jump(): # JUMP BACK ONTO PLATFORM
	if JumpTimer.time_left <= 0.0:
		if bCanJump:
			JumpTimer = get_tree().create_timer(2.5,false)
		if !bYieldStop:
			yield(JumpTimer,"timeout")
			if !bPlayer:
				bCanJump = false
				Velocity.y -= (position.y + heightLevel) * 1.15
# ------------------------------------------------------------------------------
func Save():
	things2Save.bFocused = self.bFocused
	.Save()
	return things2Save
# ------------------------------------------------------------------------------
