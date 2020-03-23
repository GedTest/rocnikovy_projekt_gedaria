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

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	if !bIsDead:
		# GRAVITY
		Velocity.y += 25 * Gravity.y
		#Move(from, to, position)
		if health <= 0:
			Death()
		
		if $HitRay.is_colliding():
			#print($HitRay.get_collider().name)
			bPlayer = true
		else:
			bPlayer = false
		
		move_and_slide(Velocity, Vector2(0,-1))

func Move(var from, var to, var Pos): # MOVE
	if !bIsDead:
		if !bPlayer:
			#if (from - Pos.x) > 0:
			if Pos.x > to:
				direction = -1
				$AnimatedSprite.flip_h = true
				$AnimatedSprite/Area2D/EnemyHitBox.position.x *= -1
				$CollisionShape2D.position.x *= -1
				
			#if (to - Pos.x) < 0:
			elif Pos.x < from:
				direction = 1
				$AnimatedSprite.flip_h = false
				$AnimatedSprite/Area2D/EnemyHitBox.position.x *= -1
				$CollisionShape2D.position.x *= -1
		#else:
			#print("I see Vlad")
		$AnimatedSprite.play("idle")
		Velocity.x = speed * direction

func Death():
	bIsDead = true
	Velocity = Vector2(0,0)
	$AnimatedSprite.play("dead")
	$CollisionShape2D.disabled = true
	$Timer.start()
	$HitRay.queue_free()

func _on_Timer_timeout():
	pass
#	queue_free()

func TakeDamage():
	health -= 5
	print("-5")

#func _on_Area2D_body_entered(body):
#	if !bIsDead:
#		# collision_layer_bit 1 = Player
#		if body.get_collision_layer_bit(1):
#			if body.position.x - position.x >= 0:
#				print("Jdu za nim")


#func _on_Area2D_body_exited(body):
#	if !bIsDead:
#		# collision_layer_bit 1 = Player
#		if body.get_collision_layer_bit(1):
#			print("ztratil se")
