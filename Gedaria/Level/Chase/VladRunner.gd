extends KinematicBody2D


const GRAVITY = Vector2(0, 70)

export var speed = 400
export var jump_strength = 1200

var velocity = Vector2(0, 0)

var is_on_ground = true
var is_slow_motion = false


func _process(delta):
	velocity.x = speed if !is_slow_motion else speed / 1.5
	velocity.y += GRAVITY.y if !is_slow_motion else GRAVITY.y / 4
	
	jump()
	crouch()
	
	velocity = move_and_slide(velocity)
# ------------------------------------------------------------------------------

func jump(): # JUMP
	if Input.is_action_just_pressed("jump"):
		is_on_ground = true if $GroundRay.is_colliding() else false
			
		if is_on_ground:
			velocity.y = -jump_strength if !is_slow_motion else -jump_strength / 2
# ------------------------------------------------------------------------------

func crouch():
	if Input.is_action_pressed("crouch"):
		$CollisionShape2D.position.y = 50
		$CollisionShape2D.scale.y = 0.5
		$AnimatedSprite.position.y = 50
		$AnimatedSprite.scale.y = 0.25
		velocity.x = speed / 1.3 if !is_slow_motion else speed / 3.5
	else:
		$CollisionShape2D.position.y = 0
		$CollisionShape2D.scale.y = 1
		$AnimatedSprite.position.y = 0
		$AnimatedSprite.scale.y = 0.5
# ------------------------------------------------------------------------------
