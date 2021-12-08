extends Level


func _ready():
	arr_patrollers = [
		$Patroller,$Patroller2,$Patroller3,$Patroller4,
		$Patroller5,$Patroller6,$Patroller7
	]
	arr_guardians = [
		$Guardian,$Guardian2
	]
	arr_shooters = [
		$Shooter,$Shooter2,$Shooter3,$Shooter4,
	]
# ------------------------------------------------------------------------------

func _on_LoadingTimer_timeout(): # Yield() doesn't work in ready() so an autostart timer is needed
	._on_LoadingTimer_timeout()
	Global.update_data_from_merchant($Vladimir)
# ------------------------------------------------------------------------------

func _process(delta):
	._process(delta)
# ------------------------------------------------------------------------------

func _on_EavesdropArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.can_stand_up = false
		body.crouch()
		$AnimationPlayer.play("eavesdrop")
		body.is_moving = false
		SaveLoad.delete_actor($EavesdropArea)
# ------------------------------------------------------------------------------

func _on_AnimationPlayer_animation_finished(anim_name):
	$Vladimir.is_moving = true
