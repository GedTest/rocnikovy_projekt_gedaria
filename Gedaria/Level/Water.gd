extends Sprite


var timer = null


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		timer = get_tree().create_timer(0.0)
		body.velocity = Vector2.ZERO
		if timer.time_left <= 0.0:
			timer = get_tree().create_timer(2.0)
			yield(timer, "timeout")
			Fullscreen.show_loading_screen()
