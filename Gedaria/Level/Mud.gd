extends Area2D


const MUD_SFX = preload("res://sfx/skok na bláto.wav")

export (float) var force = 0.5
export (float) var speed = 0.65


func _on_Mud_body_entered(body):
	if body.get_collision_layer_bit(1):
		AudioManager.play_sfx(MUD_SFX, 1, 0, -10)
		body.jump_strength *= force
		body.modify_speed *= speed
# ------------------------------------------------------------------------------

func _on_Mud_body_exited(body):
	if body.get_collision_layer_bit(1):
		body.jump_strength /= force
		body.modify_speed /= speed
# ------------------------------------------------------------------------------
