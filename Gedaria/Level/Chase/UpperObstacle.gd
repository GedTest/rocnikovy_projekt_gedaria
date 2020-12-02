extends StaticBody2D


var speed = 0


func _process(delta):
	position.x -= speed
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	$Particles2D.emitting = true
# ------------------------------------------------------------------------------

func _on_VisibilityNotifier2D_viewport_entered(viewport):
	speed = 1.25
