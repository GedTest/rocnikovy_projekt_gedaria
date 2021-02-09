extends Node2D


onready var arr_patrollers = [
	$Patroller,$Patroller2,$Patroller3,$Patroller4,$Patroller5,
	$Patroller6,$Patroller7,$Patroller8,$Patroller9,$Patroller10,
	$Patroller11,$Patroller12,$Patroller13,
]
onready var arr_guardians = [
	$Guardian,$Guardian2,$Guardian3,$Guardian4,$Guardian5,
	$Guardian6,
]
onready var arr_shooters = [
	$Shooter,$Shooter2,$Shooter3,$Shooter4,
	$Shooter5,$Shooter6,$Shooter7,$Shooter8,
	$Shooter9,$Shooter10,$Shooter11,$Shooter12,
	$Shooter13,
]
var arr_enemies = null
var is_yield_paused = false
var enabled_animation = false


func _ready():
	Global.set_player_position_at_start($Vladimir, $Level_start)
	
	get_tree().set_pause(true)
	SaveLoad.load_map()
	
	$Vladimir.heavy_attack_counter = 4
	$Vladimir.has_learned_attack = true
	$Vladimir.has_learned_heavy_attack = true
	$Vladimir.has_learned_blocking = true
	$Vladimir.has_learned_raking = true
# ------------------------------------------------------------------------------

func _on_LoadingTimer_timeout():
	SaveLoad.update_current_data()
	yield(get_tree().create_timer(0.1), "timeout")
	
	get_tree().set_pause(false)
	Global.is_yield_paused = false
	Global.is_pausable = true
	
	for leaf_holder in $LeafHolders.get_children():
		if leaf_holder.has_leaf:
			leaf_holder.show_leaf()
			
			
	var vladimir_data = "[res://Level/MerchantSquirrel.tscn, Vladimir]"
	#print("vladimir_data: ", vladimir_data)
	
	#print("has data? ",SaveLoad.slots["slot_4"].has(vladimir_data))
	#if SaveLoad.slots["slot_4"][vladimir_data]:
	#	$Vladimir.set_values(SaveLoad.slots["slot_4"][vladimir_data])
		
	$CanvasLayer/UserInterface.load_ui_icons()
	arr_enemies = arr_guardians + arr_patrollers + arr_shooters
# ------------------------------------------------------------------------------

func _process(delta):
	for i in arr_patrollers:
		i.move(i.from, i.to)
		
	for i in arr_guardians:
		i.move()
		
	if $PilesOfLeaves/PileOfLeaves7.is_complete:
		$Winds/Wind10.rotation_degrees = 210
		$Winds/Wind10.impulse = Vector2(700, -2400)
# ------------------------------------------------------------------------------

func _on_Mushroom_tree_exited():
	if enabled_animation:
		$AnimationPlayer.play("secret_passage")
		$Vladimir.can_move = false
	$InvisibleWall.queue_free()
# ------------------------------------------------------------------------------

func _on_KillZone_body_entered(body):
	if body.get_collision_layer_bit(1):
		yield(get_tree().create_timer(0.25), "timeout")
		body.die()
# ------------------------------------------------------------------------------

func _on_AnimationPlayer_animation_finished(anim_name):
	$Vladimir/Camera.current = true
	$Vladimir.can_move = true
	print("wtf")
	$TutorialSign.position = Vector2(6430, 6035)
# ------------------------------------------------------------------------------

func _on_DisableAnimation_body_entered(body):
	if body.get_collision_layer_bit(1):
		enabled_animation = true
