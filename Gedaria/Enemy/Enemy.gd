class_name Enemy, "res://Enemy/sprites/_IDLE/_IDLE_000.png"
extends KinematicBody2D


const GRAVITY = Vector2(0, 25)

var FoV = 250
var direction = 1
var velocity = Vector2(0, 0)

export(int) var health = 15
export(int) var speed = 250
export(int) var from = 0
export(int) var to = 0

var hit_in_row = 0
var damage = 2

var is_dead = false        # bIsDead
var has_player = false     # bPlayer
var can_attack = false     # bCanAttack
var is_attacking = false   # bAttacking
var is_blocking = false    # bBlocking
var is_timeout = false     # bTimeout
var is_on_ground = false   # bOnGround

var player = null
var attack_timer = null


func _ready():
	attack_timer = Timer.new()
	attack_timer.set_one_shot(true)
	attack_timer.set_wait_time(1.5)
	attack_timer.connect("timeout", self, "on_AttackTimeout")
	add_child(attack_timer)
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _physics_process(delta):
	if !is_dead:
		$CollisionShape2D.disabled = false
	# GRAVITY
		velocity.y += GRAVITY.y
	# IS IT ALIVE ?
		if health <= 0:
			die()
	
		if $HitRay.is_colliding() and $HitRay.get_collider().name == "Vladimir":
			player = $HitRay.get_collider()
			has_player = true
			$AnimatedSprite/WeaponHitbox/CollisionShape2D.disabled = false # in anim frames
		else:
			has_player = false
			$AnimatedSprite/WeaponHitbox/CollisionShape2D.disabled = true # in anim frames
			
		if can_attack:
			attack()
	
		velocity = move_and_slide(velocity)
# ------------------------------------------------------------------------------

# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func move(var from, var to, var Pos): # MOVE
	if !is_dead:
		
		is_on_ground = true if $GroundRay.is_colliding() else false
		if !is_on_ground:
			#print(name," is not on ground")
			position.x = (to + from) / 2
		if !can_attack:
			$AnimatedSprite.play("run")
	# MOVE FROM 'A' TO 'B'
		if !has_player:
			if Pos.x > to:
				direction = -1
				turn(true)
				$HitRay.cast_to.x = -FoV
		
			elif Pos.x < from:
				direction = 1
				turn(false)
				$HitRay.cast_to.x = FoV
	# FOLLOW PLAYER OR NOT
		if has_player:
			if (player.position.x <= position.x+FoV) and (player.position.x > position.x):
			# MOVE TOWARDS PLAYER (RIGHT)
				if !can_attack:
					direction = 1
					turn(false)
					$HitRay.cast_to.x = FoV
			# WALKING BACKWARDS
				else:
					yield(get_tree().create_timer(2.5), "timeout")
					direction = -1
					$HitRay.enabled = false
		
			elif (player.position.x >= position.x-FoV) and (player.position.x < position.x):
				# MOVE TOWARDS PLAYER (LEFT)
				if !can_attack:
					direction = -1
					turn(true)
					$HitRay.cast_to.x = -FoV
				# WALKING BACKWARDS
				else:
					yield(get_tree().create_timer(2.5), "timeout")
					direction = 1
					$HitRay.enabled = false
			
			yield(get_tree().create_timer(1), "timeout")
			$HitRay.enabled = true
			
		# WALKING BACKWARDS
		#	if can_attack:
		#		yield(get_tree().create_timer(2),"timeout")
		#		if player.position.x <= position.x+FoV and player.position.x >= position.x:
		#			print("On Right")
		#			$HitRay.enabled = false
		#			direction = -1
		#
		#		elif player.position.x >= position.x-FoV and player.position.x <= position.x:
		#			print("On Left")
		#			direction = 1
		#			$HitRay.enabled = false
		#			
		#	yield(get_tree().create_timer(1),"timeout")
		#	$HitRay.enabled = true
	
		velocity.x = speed * direction
# ------------------------------------------------------------------------------

func die(): # CHARACTER DIES
	health = 0
	can_attack = false
	is_dead = true
	velocity = GRAVITY
	$AnimatedSprite.play("dead")
	$CollisionShape2D.disabled = true
	$AnimatedSprite/WeaponHitbox/CollisionShape2D.disabled = true
	attack_timer.stop()
# ------------------------------------------------------------------------------

func save(): # SAVE POSITION AND VARIABLES IN JSON
	var savedData = {
		"is_dead":is_dead,
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

func turn(var event): # FLIP CHARACTER AND IT'S COMPONENTS
	var turn = 1 if event else -1
	$AnimatedSprite.flip_h = event
	$AnimatedSprite/WeaponHitbox.position.x *= turn
	$CollisionShape2D.position.x *= turn
# ------------------------------------------------------------------------------

func attack(): # DO ATTACK
	velocity.x = 0
	$AnimatedSprite.play("attack")
	# if it can attack and Player is within a range
	if is_attacking and player and has_player:
		is_attacking = false
		player.health -= damage
		print("Vladimir's health: ", player.health)
# ------------------------------------------------------------------------------

func on_AttackTimeout(): # SET COOLDOWN
	is_attacking = true
	attack_timer.start()
# ------------------------------------------------------------------------------
# NEED BETTER ANIMATIONS

func _on_WeaponHitbox_body_entered(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		can_attack = true
		attack_timer.start()
# ------------------------------------------------------------------------------

func _on_WeaponHitbox_body_exited(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		can_attack = false
# ------------------------------------------------------------------------------
