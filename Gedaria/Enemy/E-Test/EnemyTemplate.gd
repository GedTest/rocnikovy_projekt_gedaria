extends KinematicBody2D

# class_name Enemy, "res://Enemy/sprites/_IDLE/_IDLE_000.png"
class_name E, "res://Enemy/sprites/_IDLE/_IDLE_000.png"

var direction = 1
var Velocity = Vector2(0,0)
var Gravity = Vector2(0,98)
var InitialPosition = Vector2()

export(int) var FoV = 250
export(int) var health
export(int) var speed
export(int) var from
export(int) var to
export(int) var damage
var distance
var movementSpeed

var bIsDead = false
var DeathAnimTime = 1.0
var bPlayer = false
var bCanAttack = false
var bAttacking = false
var bBlocking = false
var bHeavyAttack = false
var bTimeout = false
var hitInRow = 0
var bYieldStop = false
var bFocused = false

var Player = null
var AttackTimer = null
var HitTimer = null
var CooldownTimer = null
var StateMachine = null

var things2Save = {}

func _ready():
	InitialPosition = position
	$HitRay.cast_to.x = FoV
	movementSpeed = speed
	CooldownTimer = get_tree().create_timer(0.0,false)
	AttackTimer = get_tree().create_timer(0.0,false)
	HitTimer = get_tree().create_timer(0.0,false)
	StateMachine = $AnimationTree.get("parameters/playback")
# ------------------------------------------------------------------------------
# warning-ignore:unused_argument
func _physics_process(delta):
	bYieldStop = Global.bYieldStop
	if !bIsDead:
	# GRAVITY
		Velocity.y += Gravity.y
	# IS IT ALIVE ?
		if health <= 0 || bIsDead:
			Death()
		# When he's dead and reload game he fell of surface...
		elif position.y > InitialPosition.y+3500:
			position.y = InitialPosition.y - 25
			$CollisionShape2D.disabled = false
			bIsDead = false
	# does he see the player ?
		if $HitRay.is_colliding() && $HitRay.get_collider().name == "Vladimir":
			Player = $HitRay.get_collider()
			bPlayer = true
		else:
			Player = null
			bPlayer = false
			
		if bPlayer && !Player.bIsDead:
			distance = abs(position.x - Player.position.x)
	
		Velocity = move_and_slide(Velocity)
# ------------------------------------------------------------------------------
func Death(): # CHARACTER DIES
	health = 0
	bCanAttack = false
	bIsDead = true
	Velocity = Gravity
	StateMachine.travel('DEATH') # play dying animation
	if !bYieldStop:
		yield(get_tree().create_timer(DeathAnimTime),"timeout")
		$CollisionShape2D.disabled = true
		$Weapon/CollisionShape2D.disabled = true
		$AnimationTree.active = false
# ------------------------------------------------------------------------------
func Save(): # SAVE VARIABLES IN DICTIONARY
	things2Save.bIsDead = self.bIsDead
	things2Save.health = self.health
	things2Save.speed = self.speed
	things2Save.damage = self.damage
	things2Save.FoV = self.FoV
	things2Save.direction = self.direction
	things2Save.from = self.from
	things2Save.to = self.to
	
	return things2Save
# ------------------------------------------------------------------------------
func Hit(dmg):
	speed = 0
	health -= dmg if !bHeavyAttack else dmg * 2
	if health > 0:
		StateMachine.travel('HIT')
		if HitTimer.time_left <= 0.0:
			HitTimer = get_tree().create_timer(0.75)
			if !bYieldStop:
				yield(HitTimer, "timeout")
				speed = movementSpeed
# ------------------------------------------------------------------------------
func _on_Weapon_body_entered(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		bCanAttack = true
# ------------------------------------------------------------------------------
func _on_Weapon_body_exited(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		bCanAttack = false
# ------------------------------------------------------------------------------
