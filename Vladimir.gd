extends KinematicBody2D

	
export var speed = 375
export var jump_strength = 500
var damage = 5

var Direction = Vector2()
var Velocity = Vector2(0,0)
const Gravity = Vector2(0,1)
const FloorVector = Vector2(0,-1)

var bIsDead = false
var bCanJump = true
var bCanAttack = false
var bSwording = false

var Enemy
var animation

func _ready():
	pass

# Called every frame. Delta is time since last frame.	
func _process(delta):
	# update anim
	if !bIsDead:
		if bSwording:
			Attack()
	#	UpdateAnimation()
	#	if Velocity.x == 0:
	#		$AnimatedSprite.flip_h = false
	#	$AnimatedSprite.flip_h = false if Velocity.x > 0 else true
	
	# GRAVITY
	Velocity.y += 25 * Gravity.y

	Jump()
	Move()
	Attack()
	
	Velocity = move_and_slide(Velocity,FloorVector) # I don't like this method, it already multiply by delta

func Jump(): # JUMP
	if Input.is_action_just_pressed("jump"):
		bCanJump = true if $GroundRay.is_colliding() else false
			
		if bCanJump:
			Velocity.y = -jump_strength
			$AnimatedSprite.play("jump")

func Move(): # MOVE
	if Input.is_action_pressed("right"):
		Direction = Vector2(1,0)
		$AnimatedSprite/WeaponHitbox.position.x *= -1
		$AnimatedSprite.flip_h = false
		
	elif Input.is_action_pressed("left"):
		Direction = Vector2(-1,0)
		$AnimatedSprite/WeaponHitbox.position.x *= -1
		$AnimatedSprite.flip_h = true
		
	else:
		Direction = Vector2(0,0)
	
	Velocity.x = Direction.x * speed # * delta
	
	animation = "move" if Velocity.x != 0  else "idle"
	$AnimatedSprite.flip_v = false
	#$AnimatedSprite.flip_h = Direction.x < 0
	$AnimatedSprite.play(animation)

func Attack(): # ATTACK
	if Input.is_action_just_pressed("attack"):
		bSwording = true

		if bSwording:		
			$AnimatedSprite.play("attack")
			
			#var t = Timer.new()
			#t.set_wait_time(0.9)
			#t.set_one_shot(true)
			#self.add_child(t)
			#t.start()
			#yield(t, "timeout")
			#t.queue_free()
			
			if bCanAttack:
				Enemy.get_parent().get_parent().TakeDamage()
				
			bSwording = false

func UpdateAnimation():
	if bCanJump:
		$AnimatedSprite.play("jump")
	else:
		var animation = "move" if Velocity.x != 0  else "idle"
		$AnimatedSprite.play(animation)

func _on_WeaponHitbox_area_entered(area):
	# collision_layer_bit 2 = Enemy
	if area.get_collision_layer_bit(2):
		Enemy = area
		bCanAttack = true

func _on_WeaponHitbox_area_exited(area):
	# collision_layer_bit 2 = Enemy
	if area.get_collision_layer_bit(2):
		bCanAttack = false
