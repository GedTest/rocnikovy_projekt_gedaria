extends Area2D


const PUDDLE_SFX = preload("res://sfx/skok do kaluže.wav")

export (float) var force = 2


func _on_PuddleMud_body_entered(body):
	if body.get_collision_layer_bit(1):
		AudioManager.play_sfx(PUDDLE_SFX)
		body.modify_speed *= force
# ------------------------------------------------------------------------------

func _on_Puddle_body_exited(body):
	if body.get_collision_layer_bit(1):
		body.modify_speed /= force
