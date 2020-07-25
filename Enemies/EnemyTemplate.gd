extends KinematicBody2D

# class_name Enemy, "res://Enemy/sprites/_IDLE/_IDLE_000.png"
class_name E, "res://Enemy/sprites/_IDLE/_IDLE_000.png"

var direction = 1
var Velocity = Vector2(0,0)
var Gravity = Vector2(0,98)

export(int) var FoV = 250
export(int) var health
export(int) var speed
export(int) var from
export(int) var to
export(int) var damage
var distance
var movementSpeed

var bIsDead = false
var bPlayer = false
var bCanAttack = false
var bAttacking = false
var bBlocking = false
var bTimeout = false
var hitInRow = 0

var Player = null
var AttackTimer = null
var HitTimer = null
var StateMachine = null

func _ready():
	movementSpeed = speed
	AttackTimer = get_tree().create_timer(0.0)
	HitTimer = get_tree().create_timer(0.0)
	StateMachine = $AnimationTree.get("parameters/playback")
# ------------------------------------------------------------------------------
# warning-ignore:unused_argument
func _physics_process(delta):
	if !bIsDead:
	# GRAVITY
		Velocity.y += Gravity.y
	# IS IT ALIVE ?
		if health <= 0:
			Death()
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
	$CollisionShape2D.disabled = true
	$Weapon/CollisionShape2D.disabled = true
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
func Hit(dmg):
	speed = 0
	health -= dmg
	StateMachine.travel('HIT')
	if HitTimer.time_left <= 0.0:
		HitTimer = get_tree().create_timer(0.75)
		yield(HitTimer, "timeout")
		speed = movementSpeed
# ------------------------------------------------------------------------------
func _on_Weapon_body_entered(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1) && bPlayer:
		bCanAttack = true
# ------------------------------------------------------------------------------
func _on_Weapon_body_exited(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		bCanAttack = false
# ------------------------------------------------------------------------------
