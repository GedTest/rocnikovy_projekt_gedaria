extends Level


var is_done_once_tutorial = true
var has_vlad_jumped_across = false


func _ready():
	# CALLING THE "BASE FUNTCION" FIRST
	$Vladimir.has_learned_heavy_attack = false
	$Vladimir.has_learned_raking = false
	$Vladimir/Camera.current = true
	$Patroller8.state_machine.call_deferred("travel", "STANDING 2")
	
	arr_patrollers = [
		$Patroller,$Patroller2,$Patroller3,$Patroller4,$Patroller5,
		$Patroller6,$Patroller7,$Patroller9,$Patroller10,$Patroller11,
	]
	arr_guardians = [
		$Guardian,$Guardian2,$Guardian3,$Guardian4,$Guardian5,
	]
	arr_shooters = [
		$Shooter,$Shooter2,$Shooter3,$Shooter4,
		$Shooter5,$Shooter6,$Shooter7,$Shooter8,
	]
# ------------------------------------------------------------------------------

func _on_LoadingTimer_timeout():
	# CALLING THE "BASE FUNTCION" FIRST
	._on_LoadingTimer_timeout()
	acorn_counter = 50
	unique_leaves_counter = 2
	
	demo_lang(Global.prefered_language)
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _process(delta):
	._process(delta)
	
	if $Patroller8.is_focused:
		$Patroller8/Sprite3.flip_h = false
		$Patroller8/Sprite2.flip_h = false
		$Patroller8.move($Patroller8.from, $Patroller8.to)
		if $Bridge.is_broken:
			$Patroller8.set_collision_mask_bit(0, false)
		
	if $PilesOfLeaves/PileOf4Leaves4.is_complete:
		$Winds/Wind.position = Vector2(35500, 7000)
		$Winds/Wind3.position = Vector2(35830, 7105)
		$PilesOfLeaves/PileOf4Leaves4.mode = RigidBody2D.MODE_STATIC
		$Tutorials/Tutorial7.position = Vector2(35310, 7140)
	
	if $Patroller5.is_dead and $Patroller4.is_dead and is_done_once:
		is_done_once = false
		$FallingTree.fall()
			
	
	if has_vlad_jumped_across:
		$BOSS_EARL.has_jumped = false
		$BOSS_EARL.move()
		
		if $BOSS_EARL.position.x <= 30580 and has_vlad_jumped_across:
			print("bruh")
			has_vlad_jumped_across = false
			$BOSS_EARL.velocity = Vector2.ZERO
			$BOSS_EARL.kick()
	
	if self.find_node("BOSS_EARL"):
		if $PilesOfLeaves/PileOf4Leaves6.is_complete:
			SaveLoad.delete_actor($BOSS_EARL)
# ------------------------------------------------------------------------------

func _on_AmbushArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		$Patroller3.from = 4500
		$Patroller3.to = 7300
		$Patroller4.position = Vector2(3440, 4675)
		$Patroller5.position = Vector2(7534, 4959)
# ------------------------------------------------------------------------------

func _on_RakingLearn_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.has_learned_raking = true
# ------------------------------------------------------------------------------

func _on_HeavyAttackLearn_body_entered(body):
	if body.get_collision_layer_bit(1):
		$HeavyAttackLearn/CollisionShape2D.set_deferred("disabled", true)
		body.has_learned_heavy_attack = true
		body.heavy_attack_counter = 8
# ------------------------------------------------------------------------------

func _on_VisibilityNotifier2D_viewport_entered(viewport):
	$Patroller3.direction = -1
	$Patroller3.speed = 350
# ------------------------------------------------------------------------------

func _on_Tutorial4_entered(body):
	if body.get_collision_layer_bit(1) and is_done_once_tutorial:
		is_done_once_tutorial = false
		$Vladimir.can_move = false
		$Tutorials/Tutorial4/Sprite.hide()
		$Tutorials/Tutorial4/AnimationPlayer.play("HEAVY_ATTACK")
		yield(get_tree().create_timer(4.5, false), "timeout")
		$Tutorials/Tutorial4.can_carousel = true
		$Tutorials/Tutorial4.show_text()
		$Vladimir.can_move = true
		$CanvasLayer/UserInterface.scale_unique_leaf()
# ------------------------------------------------------------------------------

func _on_KickDownArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		has_vlad_jumped_across = true
		$BOSS_EARL.has_jumped = false
		$BOSS_EARL.is_cutscene_finished = true
		body.stop_moving_during_cutsene(1.75)
		$KickDownArea/CollisionShape2D.set_deferred("disabled", true)










func _on_lang_btn_pressed(lang):
	demo_lang(lang)
func demo_lang(lang):
	if lang == "čeština":
		$DEMO_TUTORIAL/Movement.bbcode_text = "[color=#004a23]A/D[/color] Pohyb"
		$DEMO_TUTORIAL/Jump.bbcode_text = "[color=#004a23]W[/color] Skok"
		$DEMO_TUTORIAL/Crouch.bbcode_text = "[color=#004a23]S[/color] Skrčení se"
		$DEMO_TUTORIAL/Attack.bbcode_text = "[color=#004a23]Levé tlačítko myši[/color] Útok"
		$DEMO_TUTORIAL/Block.bbcode_text = "[color=#004a23]Mezerník[/color] Blokování"
	elif lang == "english":
		$DEMO_TUTORIAL/Movement.bbcode_text = "[color=#004a23]A/D[/color] Movement"
		$DEMO_TUTORIAL/Jump.bbcode_text = "[color=#004a23]W[/color] Jump"
		$DEMO_TUTORIAL/Crouch.bbcode_text = "[color=#004a23]S[/color] Crouch"
		$DEMO_TUTORIAL/Attack.bbcode_text = "[color=#004a23]Left mouse button[/color] Attack"
		$DEMO_TUTORIAL/Block.bbcode_text = "[color=#004a23]Spacebar[/color] Block"


