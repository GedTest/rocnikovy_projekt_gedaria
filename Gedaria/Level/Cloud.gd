class_name clouds, "res://Level/Prologue/cloud1.png"
extends Sprite


export(float) var speed

var can_fly = false


func _process(delta):
	if can_fly:
		position.x += speed
# ------------------------------------------------------------------------------

func _on_VisibilityNotifier2D_screen_exited():
	position.x = 0
# ------------------------------------------------------------------------------

func _on_VisibilityNotifier2D_viewport_entered(viewport):
	can_fly = true
