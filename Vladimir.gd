extends KinematicBody2D

class_name Vladimir, "res://Vladimir/animations/sprites/vladimir.png"

export var speed = 375
export var jumpStrength = 500
var damage = 5
var health = 20

var Direction = Vector2()
var Velocity = Vector2(0,0)
const Gravity = Vector2(0,25)
const FloorVector = Vector2(0,-1)

var bIsDead = false
var bCanJump = true
var bCanAttack = false
var bSwording = false
var bBlocking = false

var Enemy = null
var animation = ""

var AttackTimer = null
var BlockTimer = null

func _ready():
	BlockTimer = get_tree().create_timer(0.0)
	AttackTimer = get_tree().create_timer(0.0)
# ------------------------------------------------------------------------------	
# warning-ignore:unused_argument
func _process(delta):
	if !bIsDead:
	# GRAVITY
		Velocity.y += Gravity.y
	# IS HE ALIVE ?
		if health <= 0:
			Death()
		
		Jump()
		Move()
		Crouch()
		Attack()
		Block()
		
	Velocity = move_and_slide(Velocity,FloorVector) # I don't like this method, it already multiply by delta
# ------------------------------------------------------------------------------
func Jump(): # JUMP
	if Input.is_action_just_pressed("jump"):
		bCanJump = true if $GroundRay.is_colliding() else false
			
		if bCanJump:
			Velocity.y = -jumpStrength
			$AnimatedSprite.play("jump")
# ------------------------------------------------------------------------------
func Move(): # MOVE
	if Input.is_action_pressed("right"):
		Direction = Vector2(1,0)
		$AnimatedSprite/WeaponHitbox.position.x = 200
		$AnimatedSprite.flip_h = false
		
	elif Input.is_action_pressed("left"):
		Direction = Vector2(-1,0)
		$AnimatedSprite/WeaponHitbox.position.x = -200
		$AnimatedSprite.flip_h = true
		
	else:
		Direction = Vector2(0,0)
	
	Velocity.x = Direction.x * speed # * delta
	
	animation = "run" if Velocity.x != 0  else "idle"
	
	$AnimatedSprite.flip_v = false
	$AnimatedSprite.play(animation)
# ------------------------------------------------------------------------------
func Crouch(): # CROUCH
	if Input.is_action_pressed("crouch"):
		$CollisionShape2D.position.y = 35
		$CollisionShape2D.scale.y = 0.6
		$AnimatedSprite.position.y = 33
		$AnimatedSprite.scale.y = 0.25
		Velocity.x = Direction.x * speed / 1.6
	else:
		$CollisionShape2D.position.y = 0
		$CollisionShape2D.scale.y = 1
		$AnimatedSprite.position.y = 0
		$AnimatedSprite.scale.y = 0.4
# ------------------------------------------------------------------------------
func Attack(): # ATTACK
	if Input.is_action_just_pressed("attack") && !bSwording && !bBlocking:
	
		$AnimatedSprite.play("attack")
		bSwording = true
		
		if bCanAttack && Enemy:
			Enemy.health -= damage
			Enemy.hitInRow += 1
			print("Enemy health: ", Enemy.health)
			
		if AttackTimer.time_left <= 0.0:
			AttackTimer = get_tree().create_timer(0.8)
			yield(AttackTimer, "timeout")
		
		bSwording = false
# ------------------------------------------------------------------------------
func Block():
	if Input.is_action_just_pressed("block"):
		$Label.show()                                 # TEMPORARY
		bBlocking = true
		
		if BlockTimer.time_left <= 0.0:
			BlockTimer = get_tree().create_timer(1.0)
			yield(BlockTimer, "timeout")
			bBlocking = false
			$Label.hide()                              # TEMPORARY
# ------------------------------------------------------------------------------
func Death(): # CHARACTER DIES
	bIsDead = true
	Velocity = Gravity
	#$AnimatedSprite.play("dead")
	self.hide()
# ------------------------------------------------------------------------------
func Save(): # SAVE POSITION AND VARIABLES IN JSON
	var savedData = {
		pos = {
			"x":position.x,
			"y":position.y
		},
		"health":health
		#"scene":get_tree().get_current_scene().filename
	}
	return savedData
# ------------------------------------------------------------------------------
func _on_WeaponHitbox_body_entered(body):
	# collision_layer_bit 2 = Enemy
	if body.get_collision_layer_bit(2):
		Enemy = body
		bCanAttack = true
# ------------------------------------------------------------------------------
func _on_WeaponHitbox_body_exited(body):
	# collision_layer_bit 2 = Enemy
	if body.get_collision_layer_bit(2):
		bCanAttack = false
# ------------------------------------------------------------------------------
