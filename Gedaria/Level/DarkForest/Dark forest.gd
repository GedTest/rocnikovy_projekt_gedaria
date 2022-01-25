extends Level


var enabled_animation = false

var DEMOlang = "english"


func _ready():
	arr_patrollers = [
		$Patroller,$Patroller2,$Patroller3,$Patroller4,$Patroller5,
		$Patroller6,$Patroller7,$Patroller8,$Patroller9,$Patroller10,
		$Patroller11,$Patroller12,$Patroller13,
	]
	arr_guardians = [
		$Guardian,$Guardian2,$Guardian3,$Guardian4,$Guardian5,
		$Guardian6,$Guardian7,
	]
	arr_shooters = [
		$Shooter,$Shooter2,$Shooter3,$Shooter4,
		$Shooter5,$Shooter6,$Shooter7,$Shooter8,
		$Shooter9,$Shooter10,$Shooter11,$Shooter12,
		$Shooter13,
	]
# ------------------------------------------------------------------------------

func _on_LoadingTimer_timeout():
	# CALLING THE "BASE FUNTCION" FIRST
	._on_LoadingTimer_timeout()
	Global.update_data_from_merchant($Vladimir)
	
	acorn_counter = 50
	unique_leaves_counter = 2
	
	if Global.first_entrance:
		$LeafHolders/LeafHolder.has_leaf = 0
		$LeafHolders/LeafHolder2.has_leaf = 0
# ------------------------------------------------------------------------------

func _process(delta):
	._process(delta)
	
	if Global.prefered_language != DEMOlang:
		DEMOlang()
	
	if $PilesOfLeaves/PileOf6Leaves2.is_complete:
		$Winds/Wind10.impulse = Vector2(700, -2400)
# ------------------------------------------------------------------------------

func _on_Mushroom_tree_exited():
	if enabled_animation:
		$AnimationPlayer.play("secret_passage")
		$Vladimir.can_move = false
		$LeafHolders/LeafHolder.has_leaf = 1
		$LeafHolders/LeafHolder2.has_leaf = 1
	$InvisibleWall.queue_free()
# ------------------------------------------------------------------------------

func _on_AnimationPlayer_animation_finished(anim_name):
	$Vladimir/Camera.current = true
	$Vladimir.can_move = true
	$TutorialSign.position = Vector2(6430, 6035)
# ------------------------------------------------------------------------------

func _on_DisableAnimation_body_entered(body):
	if body.get_collision_layer_bit(1):
		enabled_animation = true


func _on_Area2D_body_entered(body, visibility):
#	if body.get_collision_layer_bit(1):
#		$entrance.visible = visibility
	pass


func _on_Area2D3_body_entered(body):
#	if body.get_collision_layer_bit(1):
#		$entrance.modulate = Color(1,1,1,0.5)
	pass


func _on_Area2D3_body_exited(body):
#	if body.get_collision_layer_bit(1):
#		$entrance.modulate = Color(1,1,1,1)
	pass



func DEMOlang():
	if Global.prefered_language == "čeština":
		$Label.show()
		$Label2.hide()
		DEMOlang = "čeština"
	elif Global.prefered_language != "čeština":
		$Label.hide()
		$Label2.show()
		DEMOlang = "english"


func _on_FallingLeafArea_body_entered(body):
	if body.get_collision_layer_bit(3):
		$LeafHolders/LeafHolder17.spawn_leaf()
		SaveLoad.delete_actor($LeafHolders/LeafHolder17)
