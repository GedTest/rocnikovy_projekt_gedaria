extends StaticBody2D
var bOnce = true

func _process(delta):
	if bOnce:
		if get_parent().find_node("Patroller5").health <= 0 && bOnce:
			bOnce = false
			$AnimationPlayer.play("fall")
			get_parent().find_node("Shake").start(5,0.5,0.25)
