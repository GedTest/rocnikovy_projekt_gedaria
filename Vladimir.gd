extends KinematicBody2D

class_name Vladimir, "res://Vladimir/animations/sprites/vladimir.png"

export(int) var speed = 525
export(int) var jumpStrength = 1700
export(int) var damage = 5
export(int) var maxHealth = 12
export(int) var health = 12

var Direction = Vector2()
var Velocity = Vector2(0,0)
const Gravity = Vector2(0,98)
const FloorNormal = Vector2(0,-1)

var bIsDead = false
var bStop = false
var bCanJump = true
var bCrouching = false
var bCanAttack = false
var bSwording = false
var bBlocking = false
var bRaking = false

var enemy : E = null
var animation = ""

var AttackTimer = null
var BlockTimer = null

func _ready():
	BlockTimer = get_tree().create_timer(0.0)
	AttackTimer = get_tree().create_timer(0.0)
# ------------------------------------------------------------------------------	
# warning-ignore:unused_argument
func _physics_process(delta):
	if !bIsDead:
		self.show()
	# GRAVITY
		Velocity.y += Gravity.y
	# IS HE ALIVE ?
		if health <= 0:
			Death()
	# IF HE'S NOT STOP BY SOME EVENT
		if !bStop:
			Jump()
			Move()
			Crouch()
			Attack()
			Block()
			Rake()
		
	Velocity = move_and_slide(Velocity,FloorNormal,false,4,PI,false) # I don't like this method, it already multiply by delta
# ------------------------------------------------------------------------------
func Jump(): # JUMP
	if Input.is_action_just_pressed("jump"):
		bCanJump = true if ($GroundRay.is_colliding() || $GroundRay2.is_colliding()) else false
			
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
		bCrouching = true
		$CollisionShape2D.position.y = 55
		$CollisionShape2D.scale.y = 0.5
		$AnimatedSprite.position.y = 55
		$AnimatedSprite.scale.y = 0.25
		Velocity.x = Direction.x * speed / 1.6
	else:
		bCrouching = false
		$CollisionShape2D.position.y = 0
		$CollisionShape2D.scale.y = 1
		$AnimatedSprite.position.y = 0
		$AnimatedSprite.scale.y = 0.5
# ------------------------------------------------------------------------------
func Attack(): # ATTACK
	if Input.is_action_just_pressed("attack") && !bSwording && !bBlocking:
	
		$AnimatedSprite.play("attack")
		position.x += 10 # move forward for better "chainng" attacks
		bSwording = true
		if enemy:
			if bCanAttack && enemy.bBlocking:
				enemy.hitInRow += 1
				enemy.StateMachine.travel('HIT_UNBLOCKABLE')
			elif bCanAttack && !enemy.bBlocking:
				enemy.Hit(damage)
				print("Enemy health: ", enemy.health)
			
		if AttackTimer.time_left <= 0.0:
			AttackTimer = get_tree().create_timer(0.8)
			yield(AttackTimer, "timeout")
		
		bSwording = false
# ------------------------------------------------------------------------------
func Block():
	if Input.is_action_just_pressed("block"):
		$Label.show()                                  # TEMPORARY
		bBlocking = true
		
		if BlockTimer.time_left <= 0.0:
			BlockTimer = get_tree().create_timer(0.5)
			yield(BlockTimer, "timeout")
			bBlocking = false
			$Label.hide()                              # TEMPORARY
# ------------------------------------------------------------------------------
func Rake(): 
	# RAKE LEAVES TO CREATE PILE OF LEAVES
	if Input.is_action_pressed("rake") && !bCrouching:
		set_collision_mask_bit(3,true)
		for index in get_slide_count():
			var collision = get_slide_collision(index)
			if collision.collider.is_in_group("leaves"):
				collision.collider.apply_impulse(Vector2(0,-30),-collision.normal * 75)
				
	# DESTROY A PILE OF LEAVES
	elif Input.is_action_just_pressed("rake_out") && !bCrouching:
		set_collision_mask_bit(3,true)
		bRaking = true
		
	else:
		set_collision_mask_bit(3,false)
		bRaking = false
# ------------------------------------------------------------------------------
func Hit(var dmg):
	health -= dmg
	get_parent().find_node("UserInterface",true,false).UpdateHealth(damage)
#	position.x = abs(position.x) - 10
	# ANIMATION
# ------------------------------------------------------------------------------
func Death(): # CHARACTER DIES
	health = 0
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
		enemy = body
		bCanAttack = true
# ------------------------------------------------------------------------------
func _on_WeaponHitbox_body_exited(body):
	# collision_layer_bit 2 = Enemy
	if body.get_collision_layer_bit(2):
		enemy = null
		bCanAttack = false
# ------------------------------------------------------------------------------
