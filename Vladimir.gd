extends KinematicBody2D

export var speed = 375
export var jump_strength = 500
var Direction = Vector2(0,0)
var Velocity = Vector2(0,0)
const Gravity = Vector2(0,1)
const FloorVector = Vector2(0,-1)

var bCanJump = true

func _ready():
	pass

#	# Called every frame. Delta is time since last frame.	
func _process(delta):
	# CAMERA
	
	# GRAVITY
	Velocity.y += 25 * Gravity.y
	
	Jump()
	Move()
	
	Velocity = move_and_slide(Velocity,FloorVector) # I don't like this method

func Jump(): # JUMP
	if Input.is_action_just_pressed("jump"):
		if bCanJump:
			Velocity.y = -jump_strength
			#$AnimatedSprite.play(animation)
	
	if is_on_floor():
		bCanJump = true
	else:
		bCanJump = false

func Move(): # MOVE
	if Input.is_action_pressed("right"):
		Direction = Vector2(1,0)
	elif Input.is_action_pressed("left"):
		Direction = Vector2(-1,0)
	else:
		Direction = Vector2(0,0)

	#Velocity.x += Direction.x * speed * delta
	Velocity.x = Direction.x * speed

	var animation = "move" if Velocity.x != 0  else "idle"
	$AnimatedSprite.flip_v = false
	$AnimatedSprite.flip_h = Direction.x < 0
	$AnimatedSprite.play(animation)