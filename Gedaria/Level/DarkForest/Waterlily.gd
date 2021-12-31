extends RigidBody2D


enum Modes {
	FLOATING,
	JUMPING,
	MOVING,
}

const PADDLING_SFX = preload("res://sfx/paddling.wav")
const RAKING_SFX = preload("res://sfx/raking.wav")
const BOUNCE_SFX = preload("res://sfx/trampoline.wav")

export(Modes) var state_mode = Modes.FLOATING
export(int) var height = 2500

var has_player = false


func _ready():
	if state_mode == Modes.FLOATING:
		self.mode = MODE_STATIC 
		$AnimatedSprite.animation = "FLOATING"
	elif state_mode == Modes.MOVING:
		self.mode = MODE_RIGID
		$AnimatedSprite.animation = "MOVING"
		$AnimatedSprite.position.y = -30
	else:
		self.mode = MODE_STATIC
		$AnimatedSprite.animation = "JUMPING"
# ------------------------------------------------------------------------------

func _process(delta):
	if has_player and state_mode == Modes.MOVING:
		if Input.is_action_pressed("rake") and not AudioManager.is_playing_sfx(PADDLING_SFX):
			AudioManager.stop_sfx(RAKING_SFX)
			AudioManager.play_sfx(PADDLING_SFX, 0, 0, -14)
	if Input.is_action_just_released("rake"):
		AudioManager.stop_sfx(PADDLING_SFX)
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1) and state_mode == Modes.JUMPING:
		AudioManager.play_sfx(BOUNCE_SFX, 1, 0, -15)
		$AnimatedSprite.frame = 0
		body.velocity.y = -height
# ------------------------------------------------------------------------------

func _on_Grab_body_entered(body, direction):
	if body.get_collision_layer_bit(4) and state_mode == Modes.MOVING:
		has_player = true
		self.apply_central_impulse(Vector2(direction * 6000, 0))
# ------------------------------------------------------------------------------

func _on_Grab_body_exited(body):
	has_player = false
