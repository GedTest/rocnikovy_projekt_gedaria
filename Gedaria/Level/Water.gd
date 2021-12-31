extends Sprite


const SPLASH_SFX = preload("res://sfx/splash.wav")

var timer = null


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		AudioManager.play_sfx(SPLASH_SFX, 0, 0, -6)
		timer = get_tree().create_timer(0.0)
		body.velocity = Vector2.ZERO
		Fullscreen.is_sign_entered = true
		
		if timer.time_left <= 0.0:
			timer = get_tree().create_timer(1.5)
			yield(timer, "timeout")
			Fullscreen.show_loading_screen()
			Fullscreen.is_sign_entered = false
