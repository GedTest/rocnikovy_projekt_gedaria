extends KinematicBody2D


const WALK_SFX = preload("res://sfx/vladimir_run.wav")
const GRAVITY = Vector2(0, 70)

export var speed = 465
export var jump_strength = 1200

var modify_speed = 1
var velocity = Vector2(0, 0)
var state_machine = null

var is_hitted = false
var is_crawling = false
var is_on_ground = true
var is_slow_motion = false


func _ready():
	AudioManager.play_sfx(WALK_SFX, 1, 0, -31)
	state_machine = $AnimationTree.get("parameters/playback")

func _process(delta):
	if not is_hitted:
		velocity.x = speed*modify_speed if not is_slow_motion else (speed/2.5)*modify_speed
		velocity.y += GRAVITY.y if not is_slow_motion else GRAVITY.y / 5
		
		jump()
		crouch()
		
		if speed != 0 && not is_crawling:
			state_machine.travel('RUN')
		
		velocity = move_and_slide(velocity)
# ------------------------------------------------------------------------------

func jump(): # JUMP
	if Input.is_action_just_pressed("jump"):
		is_on_ground = true if $GroundRay.is_colliding() else false
			
		if is_on_ground:
			velocity.y = -jump_strength if not is_slow_motion else -jump_strength / 2
# ------------------------------------------------------------------------------

func crouch():
	if Input.is_action_pressed("crouch"):
		is_crawling = true
		$CollisionShape2D.position.y = 50
		$CollisionShape2D.scale.y = 0.5
		state_machine.travel('CRAWLING')
		velocity.x = speed / 1.5 if not is_slow_motion else speed / 4
	else:
		is_crawling = false
		$CollisionShape2D.position.y = 0
		$CollisionShape2D.scale.y = 1
# ------------------------------------------------------------------------------
