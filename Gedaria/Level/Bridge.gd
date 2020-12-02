extends StaticBody2D


var timer = null



func _ready():
	timer = get_tree().create_timer(0.0, false)
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	# collision layer 1 = Player
	if body.get_collision_layer_bit(1) or body.get_collision_layer_bit(2):
		if timer.time_left <= 0.0:
			timer = get_tree().create_timer(1.0, false)
			yield(timer, "timeout")
			# BREAKING ANIMATION
			SaveLoad.delete_actor(self)
