extends RigidBody2D


enum Modes {
	FLOATING,
	JUMPING,
	MOVING,
}

export(Modes) var state_mode = Modes.FLOATING
export(int) var height = 2500


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

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1) and state_mode == Modes.JUMPING:
		$AnimatedSprite.frame = 0
		body.velocity.y = -height
# ------------------------------------------------------------------------------

func _on_Grab_body_entered(body, direction):
	if body.get_collision_layer_bit(5) and state_mode == Modes.MOVING:
		self.apply_central_impulse(Vector2(direction * 6000, 0))
