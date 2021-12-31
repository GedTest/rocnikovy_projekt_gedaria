extends Level


func _ready():
	$CanvasLayer/ParallaxBackground.layer = -99
	arr_patrollers = [
		$Patroller,$Patroller2,$Patroller3,$Patroller4,
		$Patroller5,$Patroller6,$Patroller7,$Patroller8
	]
	arr_guardians = [
		$Guardian,$Guardian2,$Guardian3
	]
	arr_shooters = [
		$Shooter,$Shooter2,$Shooter3,
		$Shooter4,$Shooter5,$Shooter6,$Shooter7
	]
# ------------------------------------------------------------------------------

func _on_LoadingTimer_timeout(): # Yield() doesn't work in ready() so an autostart timer is needed
	._on_LoadingTimer_timeout()
	Global.update_data_from_merchant($Vladimir)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	if $Vladimir.position.x > 8250:
		$CanvasLayer/ParallaxBackground.layer = -101
# ------------------------------------------------------------------------------

func _process(delta):
	._process(delta)
	
	if $Vladimir.position.x < 8250:
		$CanvasLayer/ParallaxBackground.layer = -99
	
	
	$Shooter6.can_shoot_in_sector = true if $Vladimir.position.y > 4450 else false
	$Shooter7.can_shoot_in_sector = true if $Vladimir.position.y > 4450 else false
# ------------------------------------------------------------------------------

func _on_EavesdropArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		$CanvasLayer/ParallaxBackground.layer = -101
		body.can_stand_up = false
		body.crouch()
		$AnimationPlayer.play("eavesdrop")
		body.is_moving = false
		body.velocity = Vector2.ZERO
		SaveLoad.delete_actor($EavesdropArea)
# ------------------------------------------------------------------------------

func _on_AnimationPlayer_animation_finished(anim_name):
	$Vladimir.is_moving = true
# ------------------------------------------------------------------------------

func _on_BarArea_body_entered(body):
	if body.get_collision_layer_bit(2) and "Patroller" in body.name:
		$AnimationPlayer.play("BARS_UP")
