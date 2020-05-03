extends KinematicBody2D

class_name Enemy, "res://Enemy/sprites/_IDLE/_IDLE_000.png"

var FoV = 250
var direction = 1
var Velocity = Vector2(0,0)
const Gravity = Vector2(0,25)

export var health = 15
export var speed = 250
export(int) var from
export(int) var to
var damage = 2

var bIsDead = false
var bPlayer = false
var bCanAttack = false
var bAttacking = false
var bTimeout = false
var bOnGround = false

var Player = null
var AttackTimer = null

func _ready():
	AttackTimer = Timer.new()
	AttackTimer.set_one_shot(true)
	AttackTimer.set_wait_time(1.5)
	AttackTimer.connect("timeout", self, "on_AttackTimeout")
	add_child(AttackTimer)
# ------------------------------------------------------------------------------
# warning-ignore:unused_argument
func _physics_process(delta):
	if !bIsDead:
		$CollisionShape2D.disabled = false
	# GRAVITY
		Velocity.y += Gravity.y
	# IS IT ALIVE ?
		if health <= 0:
			Death()
	
		if $HitRay.is_colliding() && $HitRay.get_collider().name == "Vladimir":
			Player = $HitRay.get_collider()
			bPlayer = true
			$AnimatedSprite/WeaponHitbox/CollisionShape2D.disabled = false # in anim frames
		else:
			bPlayer = false
			$AnimatedSprite/WeaponHitbox/CollisionShape2D.disabled = true # in anim frames
			
		if bCanAttack:
			Attack()
	
		Velocity = move_and_slide(Velocity)
# ------------------------------------------------------------------------------
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func Move(var from, var to, var Pos): # MOVE
	if !bIsDead:
		
		bOnGround = true if $GroundRay.is_colliding() else false
		if !bOnGround:
			position.x = ((to - from) / 2) + from
		if !bCanAttack:
			$AnimatedSprite.play("run")
	# MOVE FROM 'A' TO 'B'
		if !bPlayer:
			if Pos.x > to:
				direction = -1
				Turn(true)
				$HitRay.cast_to.x = -FoV
		
			elif Pos.x < from:
				direction = 1
				Turn(false)
				$HitRay.cast_to.x = FoV
	# FOLLOW PLAYER OR NOT
		if bPlayer:
			if Player.position.x <= position.x+FoV && Player.position.x > position.x:
			# MOVE TOWARDS PLAYER (RIGHT)
				if !bCanAttack:
					direction = 1
					Turn(false)
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
					Turn(true)
					$HitRay.cast_to.x = -FoV
				# WALKING BACKWARDS
				else:
					yield(get_tree().create_timer(2.5),"timeout")
					direction = 1
					$HitRay.enabled = false
			
			yield(get_tree().create_timer(1),"timeout")
			$HitRay.enabled = true
			
		# WALKING BACKWARDS
		#	if bCanAttack:
		#		yield(get_tree().create_timer(2),"timeout")
		#		if Player.position.x <= position.x+FoV && Player.position.x >= position.x:
		#			print("On Right")
		#			$HitRay.enabled = false
		#			direction = -1
		#
		#		elif Player.position.x >= position.x-FoV && Player.position.x <= position.x:
		#			print("On Left")
		#			direction = 1
		#			$HitRay.enabled = false
		#			
		#	yield(get_tree().create_timer(1),"timeout")
		#	$HitRay.enabled = true
	
		Velocity.x = speed * direction
# ------------------------------------------------------------------------------
func Death(): # CHARACTER DIES
	bCanAttack = false
	bIsDead = true
	Velocity = Gravity
	$AnimatedSprite.play("dead")
	$CollisionShape2D.disabled = true
	$AnimatedSprite/WeaponHitbox/CollisionShape2D.disabled = true
	AttackTimer.stop()
# ------------------------------------------------------------------------------
func Save(): # SAVE POSITION AND VARIABLES IN JSON
	var savedData = {
		"bIsDead":bIsDead,
		"health":health,
		pos = {
			"x":position.x,
			"y":position.y
		},
		"from":from,
		"to":to
	}
	return savedData
# ------------------------------------------------------------------------------
# TODO: remove frozen timer 2:20
# ------------------------------------------------------------------------------
func Turn(var event): # FLIP CHARACTER AND IT'S COMPONENTS
	$AnimatedSprite.flip_h = event
	$AnimatedSprite/WeaponHitbox.position.x *= -1
	$CollisionShape2D.position.x *= -1
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
# NEED BETTER ANIMATIONS
func _on_WeaponHitbox_body_entered(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		bCanAttack = true
		AttackTimer.start()
# ------------------------------------------------------------------------------
func _on_WeaponHitbox_body_exited(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		bCanAttack = false
# ------------------------------------------------------------------------------
