extends StaticBody2D


const COLLAPSING_SFX = preload("res://sfx/collapsing.wav")


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		AudioManager.play_sfx(COLLAPSING_SFX, 1, -1.0, -10)
		$AnimationPlayer.play("BREAKING")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "BREAKING":
		SaveLoad.delete_actor(self)
