extends StaticBody2D


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		$AnimationPlayer.play("BREAKING")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "BREAKING":
		SaveLoad.delete_actor(self)
