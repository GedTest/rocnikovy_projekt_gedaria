class_name Vladimir, "res://Vladimir/animations/sprites/vladimir.png"
extends KinematicBody2D

var pebblePath = preload("res://Vladimir/Pebble.tscn")

export(int) var speed = 525
export(int) var modifySpeed = 1
export(int) var jumpStrength = 1700
export(int) var damage = 5
export(int) var maxHealth = 12
export(int) var health = 12
export(int) var pebbleCounter = 0
var ShootDistance = 500
var acornCounter = 0
var next_pos_ID = ""

var direction = 1
var attackDirection = 1
var Velocity = Vector2(0, 0)
const Gravity = Vector2(0, 98)
const FloorNormal = Vector2(0, -1)
var mousePosition = Vector2(0, 0)
var jumpedHeight = Vector2(0, 0)

var bIsDead = false
var bStop = false
var bCanMove = true
var bCanJump = true
var bCrouching = false
var bCanAttack = false
var bSwording = false
var bBlocking = false
var bHidden = false
var bAimining = false
var bHit = false
var bRake = false
var bYieldStop = false
var bHasSlingshot = false

var bAttackLearned = true
var bHeavyAttackLearned = true
var bRakingLearned = true
var bBlockingLearned = true

var enemy : E = null

var AttackTimer = null
var HeavyAttackTimer = null
var BlockTimer = null
var StateMachine = null


func _ready():
	set_collision_layer_bit(1, true)
	StateMachine = $AnimationTree.get("parameters/playback")
	BlockTimer = get_tree().create_timer(0.0)
	AttackTimer = get_tree().create_timer(0.0)
	HeavyAttackTimer = get_tree().create_timer(0.0)
# ------------------------------------------------------------------------------	

# warning-ignore:unused_argument
func _physics_process(delta):
	if !bIsDead:
		bYieldStop = get_parent().bYieldStop
		update() # Draw function
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
			if bAttackLearned:
				Attack()
			if bHeavyAttackLearned:
				HeavyAttack()
			Shoot()
			if bBlockingLearned:
				Block()
			if bRakingLearned:
				Rake()
		
			# I don't like this method, it already multiply by delta
			Velocity = move_and_slide(Velocity, FloorNormal, \
									  false, 4, PI,false)
# ------------------------------------------------------------------------------

func Jump(): # JUMP
	if Input.is_action_just_pressed("jump"):
		bCanJump = true if ($GroundRay.is_colliding() or $GroundRay2.is_colliding()) else false
			
		if bCanJump:
			jumpedHeight.y = position.y
			Velocity.y = -jumpStrength
# ------------------------------------------------------------------------------

func Move(): # MOVE
	if Input.is_action_pressed("right") and !bRake:
		direction = 1
		attackDirection = 1
		$Sprite.flip_h = false
		
	elif Input.is_action_pressed("left") and !bRake:
		direction = -1
		attackDirection = -1
		$Sprite.flip_h = true
		
	else:
		direction = 0
	
	Velocity.x = direction * (speed * modifySpeed) * int(bCanMove) # * delta
	var animation = "RUN" if Velocity.x != 0  else "IDLE"
	
	$Sprite.flip_v = false
	if !bHit and !bSwording and !bRake and !bIsDead:
		StateMachine.travel(animation)

# ------------------------------------------------------------------------------
func Crouch(): # CROUCH
	var bCanStandUp = false if $CeilingRay.is_colliding() else true
	
	if (Input.is_action_pressed("crouch") and !bHit) or !bCanStandUp:
		bCrouching = true
		$CollisionShape2D.position.y = 35
		$CollisionShape2D.scale.y = 0.825
		StateMachine.travel('CRAWLING')
		Velocity.x = direction * speed / 1.6
		
	else:
		bCrouching = false
		$CollisionShape2D.position.y = 22
		$CollisionShape2D.scale.y = 1
# ------------------------------------------------------------------------------

func Attack(): # LIGHT ATTACK, fast but low dmg,
	if Input.is_action_just_pressed("attack") and !bSwording and !bBlocking:
		bSwording = true
		bCanMove = false
		$AnimationTree.set("parameters/ATTACK/blend_position", attackDirection)
		StateMachine.travel('ATTACK')
		
		if AttackTimer.time_left <= 0.0:
			AttackTimer = get_tree().create_timer(0.656)
			if !bYieldStop:
				yield(AttackTimer, "timeout")
				if enemy and bCanAttack:
					enemy.Hit(damage)
					print("Enemy health: ", enemy.health)
				
				bCanMove = true
				bSwording = false
# ------------------------------------------------------------------------------

func HeavyAttack(): # HEAVY ATTACK, slow but high dmg
	if Input.is_action_just_pressed("heavy attack") and !bSwording and !bBlocking:
		$AnimationTree.set("parameters/HEAVY_ATTACK/blend_position", attackDirection)
		StateMachine.travel('HEAVY_ATTACK')
		
		if HeavyAttackTimer.time_left <= 0.0:
			HeavyAttackTimer = get_tree().create_timer(1.25)
			if !bYieldStop:
				yield(HeavyAttackTimer, "timeout")
				
				if enemy and bCanAttack:
					enemy.bHeavyAttack = true
					enemy.Hit(damage)
					#enemy.position.x -= 200 * enemy.direction
# ------------------------------------------------------------------------------

func Shoot():
	if Input.is_action_pressed("shoot") and pebbleCounter > 0 and !bCrouching:
		bCanMove = false
		bAimining = true
		mousePosition = get_local_mouse_position()
		var animation = "SLINGSHOT" if bHasSlingshot else "PEBBLE"
		StateMachine.travel("HOLD_" + animation)
		
		if Input.is_action_just_pressed("attack"):
			bCanMove = true
			
			var pebble = pebblePath.instance()
			get_parent().add_child(pebble)
			pebble.position = $Position2D.global_position
			
			if bHasSlingshot:
				pebble.bCanDamage = true
				
			StateMachine.travel("RELEASE_" + animation)
			pebbleCounter -= 1
			get_parent().find_node("UserInterface").UpdatePebbles(1, "minus", pebbleCounter)
			
	if Input.is_action_just_released("shoot"):
		bCanMove = true
		bAimining = false
# ------------------------------------------------------------------------------

func Block(): # BLOCK INCOMING DAMAGE
	if Input.is_action_just_pressed("block"):
		StateMachine.travel('BLOCKING')
		bBlocking = true
		
		if BlockTimer.time_left <= 0.0:
			BlockTimer = get_tree().create_timer(0.7)
			if !bYieldStop:
				yield(BlockTimer, "timeout")
				bBlocking = false
# ------------------------------------------------------------------------------

func Rake(): # RAKE LEAVES TO CREATE PILE OF LEAVES
	if Input.is_action_just_released("rake"):
		bRake = false
		$AnimationTree.active = false
		$AnimationTree.active = true
		
	if Input.is_action_pressed("rake") and !bCrouching:
		bRake = true
		Velocity.x = -direction * speed / 2
		$AnimationTree.set("parameters/RAKING/blend_position", attackDirection)
		StateMachine.travel('RAKING')
		for index in $LeavesCollector.get_slide_count():
			var collision = $LeavesCollector.get_slide_collision(index)
			if collision.collider.is_in_group("leaves"):
				collision.collider.apply_central_impulse(collision.normal * 20)
		yield(get_tree().create_timer(1.35,false), "timeout")
		bRake = false
		
	# DESTROY A PILE OF LEAVES
	elif Input.is_action_just_pressed("attack") and !bCrouching:
		StateMachine.travel('ATTACK')
# ------------------------------------------------------------------------------

func Hit(var dmg):
	if !bIsDead:
		get_parent().find_node("UserInterface").UpdateHealth(dmg, 'minus', health, maxHealth)
		health -= dmg
		bHit = true
		if health > 1:
			StateMachine.travel('HIT')
		if !bYieldStop:
			yield(get_tree().create_timer(0.95, false), "timeout")
			bHit = false
# ------------------------------------------------------------------------------

func Death(): # CHARACTER DIES
	health = 0
	bIsDead = true
	set_collision_layer_bit(1, false)
	Velocity = Gravity
	StateMachine.travel('DEATH')
	Global.bYieldStop = true
	# Load checkpoint
	SaveLoad.load_from_slot("checkpoint")
	yield(get_tree().create_timer(2.2, false), "timeout")
	$AnimationTree.active = false
# ------------------------------------------------------------------------------

func Save(): # SAVE VARIABLES IN DICTIONARY
	var savedData = {
		"health":health,
		"maxHealth":maxHealth,
		"pebbleCounter":pebbleCounter,
		"acornCounter":acornCounter,
		"speed":speed,
		"damage":damage,
		"bHasSlingshot":bHasSlingshot
	}
	return savedData
# ------------------------------------------------------------------------------

func _on_WeaponHitbox_body_entered(body):
	# collision_layer_bit 2 = Enemy
	if body.get_collision_layer_bit(2):
		enemy = body if body.name != "Shield" else body.get_parent()
		bCanAttack = true
# ------------------------------------------------------------------------------

func _on_WeaponHitbox_body_exited(body):
	# collision_layer_bit 2 = Enemy
	if body.get_collision_layer_bit(2):
		enemy = null
		bCanAttack = false
# ------------------------------------------------------------------------------

func _draw(): # ENGINE DRAW FUNCTION
	if bAimining:
		draw_line(Vector2(0, 0), mousePosition, Color(1.0, 1.0, 1.0, 0.3), 8.0)
