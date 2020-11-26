extends Sprite

class_name clouds, "res://Level/Prologue/cloud1.png"
export(float) var speed
var bCanFly = false

func _process(delta):
	if bCanFly:
		position.x += speed
	
func _on_VisibilityNotifier2D_screen_exited():
	position.x = 0

func _on_VisibilityNotifier2D_viewport_entered(viewport):
	bCanFly = true
