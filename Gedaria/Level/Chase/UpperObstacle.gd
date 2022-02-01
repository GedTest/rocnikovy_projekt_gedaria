extends StaticBody2D


const CROW_SFX = preload("res://sfx/crow.wav")

var speed = 0
var is_flying = false


func _physics_process(delta):
	position.x -= speed
	
	if $RayCast2D.is_colliding() and is_flying:
		$RayCast2D.enabled = false
		speed /= 1.7
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	$Particles2D.emitting = true
	AudioManager.play_sfx(CROW_SFX, 1, 0, -11)
# ------------------------------------------------------------------------------

func _on_VisibilityNotifier2D_viewport_entered(viewport):
	speed = 1.5
	is_flying = true
