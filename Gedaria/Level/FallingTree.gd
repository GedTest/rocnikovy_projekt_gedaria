extends StaticBody2D


var is_done_once = true


func _process(delta):
	if is_done_once:
		if get_parent().find_node("Patroller5").health <= 0 && is_done_once:
			is_done_once = false
			$AnimationPlayer.play("fall")
			get_parent().find_node("Shake").start(5, 0.5, 0.25)
