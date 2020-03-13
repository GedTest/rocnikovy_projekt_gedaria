extends KinematicBody2D

export var speed = 374.14
export var jump_strength = 500
var Direction = Vector2(0,0)
var Velocity = Vector2(0,0)
const Gravity = 25
const FloorVector = Vector2(0,-1)

func _ready():
	pass

#	# Called every frame. Delta is time since last frame.	
func _process(delta):
	# GRAVITY
	Velocity.y += Gravity
	
	Jump()
	Move()
	
	Velocity = move_and_slide(Velocity,FloorVector)

func Jump(): # JUMP
	if Input.is_action_just_pressed("jump"):
		Velocity.y = -jump_strength

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