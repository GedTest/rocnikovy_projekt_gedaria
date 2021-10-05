extends Sprite


var is_interactable = false
var direction = 1


func _process(delta):
	if Input.is_action_just_pressed("interact") and is_interactable:
		$Tween.interpolate_property(self, "position", position, Vector2(position.x, position.y-(185*direction)), 0.8, Tween.TRANS_BACK, Tween.EASE_OUT)
		$Tween.start()
		direction *= -1
# ------------------------------------------------------------------------------

func _on_Area_body_entered(body):
	is_interactable = true
# ------------------------------------------------------------------------------

func _on_Area_body_exited(body):
	is_interactable = false
