extends E

var bCanThrow = false
var bThrowing = false
var bDoOnce = true
var distance
var boost = 1
var startingHealth

var stateMachine
var ThrowTimer = null
var HitTimer = null

func _ready():
	FoV = 1000
	stateMachine = $AnimationTree.get("parameters/playback")
	startingHealth = health
	
	HitTimer = get_tree().create_timer(0.0)
	ThrowTimer = get_tree().create_timer(0.0)
# ------------------------------------------------------------------------------
func _process(delta):
	if !bIsDead:
		if health == startingHealth / 2 && bDoOnce:
			bDoOnce = false
			bCanThrow = true
		
		if $HitRay.is_colliding() && $HitRay.get_collider().name == "Vladimir" || $HitRay2.is_colliding() && $HitRay2.get_collider().name == "Vladimir":
			Player = $HitRay.get_collider() if $HitRay.get_collider() != null else $HitRay2.get_collider()
			bPlayer = true
			$AnimatedSprite/WeaponHitbox/CollisionShape2D.disabled = false
		else:
			Player = null
			bPlayer = false
			$AnimatedSprite/WeaponHitbox/CollisionShape2D.disabled = true
		
		if health > startingHealth / 2:
			if hitInRow == 3:
				Player.damage = 5
				speed = 0
				if HitTimer.time_left <= 0.0:
					HitTimer = get_tree().create_timer(4)
					yield(HitTimer,"timeout")
					hitInRow = 0
					speed = 175
				
			elif hitInRow > 0 && hitInRow < 3:
				if Player:
					Player.damage = 0
				if HitTimer.time_left <= 0.0:
					HitTimer = get_tree().create_timer(3)
					yield(HitTimer,"timeout")
					hitInRow = 0
		
		Velocity = move_and_slide(Velocity)
# ------------------------------------------------------------------------------
func Move_children(): # HANDLE MOVEMENT
	if !bIsDead:
		# MOVE FROM 'A' TO 'B'
		if !bPlayer:
			if position.x > to:
				direction = -1
				Turn(true)
				$RakeProjektil/Sprite.flip_h = true
				$HitRay2.cast_to.x = -FoV
			
			elif position.x < from:
				direction = 1
				Turn(false)
				$RakeProjektil/Sprite.flip_h = false
				$HitRay2.cast_to.x = FoV
			
		elif bPlayer:
			distance = abs(position.x - Player.position.x)
			if distance <= 80 && !bAttacking && (!bCanThrow || !bThrowing):
				Attack(direction)
				
			if health < startingHealth / 2:
				if distance < 200 && bCanThrow:
					Jump()
					
				elif distance > 200 && distance < 350 && bCanThrow:
					Throw(direction)
					bCanThrow = false
			else:
				Dash()
			
		Velocity.x = speed * direction * boost
# ------------------------------------------------------------------------------		
func Attack(dir): # PRIMARY ATTACK - THRESH
	speed = 0 # Stop moving
	var animDirection = "attackRight" if dir == 1 else "attackLeft"
	stateMachine.travel(animDirection)
	
	if Player && bPlayer && bCanAttack:
		bAttacking = true
		if !Player.bBlocking:
			Player.health -= damage
			print("Vladimir's health: ", Player.health)
		
	if AttackTimer.time_left <= 0.0:
		AttackTimer = get_tree().create_timer(3.0)
		yield(AttackTimer, "timeout")
		bAttacking = false
		speed = 175
# ------------------------------------------------------------------------------
func Dash(): # SPEEDS UP AND DASHes TOWARD THE PLAYER
	if distance > 450:
		#print("dash")
		boost = 2
	else:
		boost = 1
# ------------------------------------------------------------------------------
func Jump(): # JUMP IN DISTANCE SO HE CAN THROW
	# ensure that BOSS can't jump out of the map
	if position.x > from +250 && position.x < to -250:
		position.x += 350 * -direction
# ------------------------------------------------------------------------------
func Throw(dir): # SECONDARY ATTACK - THROW
	speed = 0 # Stop moving
	bThrowing = true
	var animDirection = "throwRight" if dir == 1 else "throwLeft"
	stateMachine.travel(animDirection)
	
	# deal the damage by projektil
	
	if ThrowTimer.time_left <= 0.0:
		ThrowTimer = get_tree().create_timer(2.75)
		yield(ThrowTimer, "timeout")
		bThrowing = false
		bCanThrow = true
		boost = 1
		speed = 175
# ------------------------------------------------------------------------------
