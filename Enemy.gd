extends KinematicBody2D

export var speed = 325
var direction = 1
var Velocity = Vector2(0,0)
const Gravity = Vector2(0,1)

export var from = 0
export var to = 0

export var health = 15
var bIsDead = false
var bPlayer = false

var PlayerPositionX
var timer = null

func _ready():
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(3)
	timer.connect("timeout", self, "on_timeout")
	add_child(timer)
# ------------------------------------------------------------------------------
func _physics_process(delta):
	if !bIsDead:
		# GRAVITY
		Velocity.y += 25 * Gravity.y
		
		if health <= 0:
			Death()
		
		if $HitRay.is_colliding() && $HitRay.get_collider().name == "Vladimir":
			PlayerPositionX = $HitRay.get_collider().position.x
			bPlayer = true
		else:
			bPlayer = false
		
			
		move_and_slide(Velocity, Vector2(0,-1))
# ------------------------------------------------------------------------------
func Move(var from, var to, var Pos): # MOVE
	if !bIsDead:
		if !bPlayer:
			#if (from - Pos.x) > 0:
			if Pos.x > to:
				direction = -1
				Turn(true)
				$HitRay.cast_to.x = -$HitRay.cast_to.x
				
			#if (to - Pos.x) < 0:
			elif Pos.x < from:
				direction = 1
				Turn(false)
				$HitRay.cast_to.x = $HitRay.cast_to.x
				
	# MOVE TOWARDS PLAYER
		if bPlayer:
			if PlayerPositionX <= position.x+100 && PlayerPositionX > position.x:
				direction = 1
				Turn(false)
				$HitRay.cast_to.x = 300
				
			if PlayerPositionX >= position.x-100 && PlayerPositionX < position.x:
				direction = -1
				Turn(true)
				$HitRay.cast_to.x = -300
				
		$AnimatedSprite.play("idle")
		Velocity.x = speed * direction
# ------------------------------------------------------------------------------
func Death(): # CHARACTER DIES
	bIsDead = true
	Velocity = Vector2(0,0)
	$AnimatedSprite.play("dead")
	$AnimatedSprite/Area2D/EnemyHitBox.disabled = true
	$CollisionShape2D.disabled = true
# ------------------------------------------------------------------------------
# TODO: remove frozen timer 2:20

func TakeDamage():
	health -= 5
	print("-5")
# ------------------------------------------------------------------------------
func Turn(var event): # FLIP CHARACTER AND IT'S COMPONENTS
	$AnimatedSprite.flip_h = event
	$AnimatedSprite/Area2D/EnemyHitBox.position.x *= -1
	$CollisionShape2D.position.x *= -1
# ------------------------------------------------------------------------------
#func on_timeout():
#	print("I am on!")
	# WALKING BACKWARDS
#	if bPlayer:
#		if PlayerPositionX <= position.x+100 && PlayerPositionX >= position.x:
#			print("On Right")
#			direction = -1
#			$HitRay.cast_to.x *= -$HitRay.cast_to.x
#		if PlayerPositionX >= position.x-100 && PlayerPositionX <= position.x:
#			print("On Left")
#			direction = 1
#			$HitRay.cast_to.x = $HitRay.cast_to.x
