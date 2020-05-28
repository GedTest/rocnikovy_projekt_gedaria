extends KinematicBody2D

# class_name Enemy, "res://Enemy/sprites/_IDLE/_IDLE_000.png"
class_name E, "res://Enemy/sprites/_IDLE/_IDLE_000.png"

var FoV = 250
var direction = 1
var Velocity = Vector2(0,0)
const Gravity = Vector2(0,25)

export(int) var health
export(int) var speed
export(int) var from
export(int) var to
export(int) var damage

var bIsDead = false
var bPlayer = false
var bCanAttack = false
var bAttacking = false
var bTimeout = false
var bOnGround = false
var hitInRow = 0

var Player = null
var AttackTimer = null

func _ready():
	AttackTimer = get_tree().create_timer(0.0) # BETTER TIMER
	#AttackTimer = Timer.new()
	#AttackTimer.set_one_shot(true)
	#AttackTimer.set_wait_time(1.5)
	#AttackTimer.connect("timeout", self, "on_AttackTimeout")
	#add_child(AttackTimer)
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
			Player = null
			bPlayer = false
			$AnimatedSprite/WeaponHitbox/CollisionShape2D.disabled = true # in anim frames
	
		Velocity = move_and_slide(Velocity)
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
func Turn(var event): # FLIP CHARACTER AND IT'S COMPONENTS
	var turn = -1 if event else 1
	$AnimatedSprite.flip_h = event
	$AnimatedSprite/WeaponHitbox.position.x *= -1
	$CollisionShape2D.scale.x = turn
	$HitRay.cast_to.x = FoV * turn
# ------------------------------------------------------------------------------
# NEED BETTER ANIMATIONS
func _on_WeaponHitbox_body_entered(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1) && bPlayer:
		bCanAttack = true
		#AttackTimer.start()
		#print("Vladimir's health: ", Player.health)
# ------------------------------------------------------------------------------
func _on_WeaponHitbox_body_exited(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		bCanAttack = false
# ------------------------------------------------------------------------------
