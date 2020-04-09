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
var bSwording = true

var Enemy
var animation

var timer = null

func _ready():
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(0.5)
	timer.connect("timeout", self, "on_timeout")
	add_child(timer)
# ------------------------------------------------------------------------------	
func _process(delta):
	
	# GRAVITY
	Velocity.y += 25 * Gravity.y
	
	Jump()
	Move()
	Attack()
	
	Velocity = move_and_slide(Velocity,FloorVector) # I don't like this method, it already multiply by delta
# ------------------------------------------------------------------------------
func Jump(): # JUMP
	if Input.is_action_just_pressed("jump"):
		bCanJump = true if $GroundRay.is_colliding() else false
			
		if bCanJump:
			Velocity.y = -jump_strength
			$AnimatedSprite.play("jump")
# ------------------------------------------------------------------------------
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
	
	animation = "run" if Velocity.x != 0  else "idle"
	
	$AnimatedSprite.flip_v = false
	#$AnimatedSprite.flip_h = Direction.x < 0
	$AnimatedSprite.play(animation)
# ------------------------------------------------------------------------------
func Attack(): # ATTACK
	if Input.is_action_just_pressed("attack") && bSwording:
	
		$AnimatedSprite.play("attack")
	
		if bCanAttack:
			Enemy.get_parent().get_parent().TakeDamage()
		bSwording = false
		timer.start()
# ------------------------------------------------------------------------------
func on_timeout():
	bSwording = true
# ------------------------------------------------------------------------------
func _on_WeaponHitbox_area_entered(area):
	# collision_layer_bit 2 = Enemy
	if area.get_collision_layer_bit(2):
		Enemy = area
		bCanAttack = true
# ------------------------------------------------------------------------------
func _on_WeaponHitbox_area_exited(area):
	# collision_layer_bit 2 = Enemy
	if area.get_collision_layer_bit(2):
		bCanAttack = false
# ------------------------------------------------------------------------------
