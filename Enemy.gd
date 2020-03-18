extends KinematicBody2D

export var speed = 325
var direction = 1
var Velocity = Vector2(0,0)
const Gravity = Vector2(0,1)

export var from = 0
export var to = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	# GRAVITY
	Velocity.y += 25 * Gravity.y
	#Move(from, to, position)
	
	move_and_slide(Velocity, Vector2(0,-1))

func Move(var from, var to, var Pos): # MOVE
	if (from - Pos.x) > 0:
		direction *= -1
		$AnimatedSprite.flip_h = false
	if (to - Pos.x) < 0:
		direction *= -1
		$AnimatedSprite.flip_h = true
	Velocity.x = speed * direction