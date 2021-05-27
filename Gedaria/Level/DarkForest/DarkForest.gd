extends Node2D


var arr_enemies = []
var is_yield_paused = false
var enabled_animation = false

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


func _ready():
	Global.set_player_position_at_start($Vladimir, $Level_start)
	Global.is_first_entrance(self.filename)
	
	get_tree().set_pause(true)
	SaveLoad.load_map()
	Fullscreen.hide_elements()
	
	$Vladimir.heavy_attack_counter += 4
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
	
	for leaf_holder in $LeafHolders.get_children():
		if leaf_holder.has_leaf:
			leaf_holder.show_leaf()
	
	Global.update_data_from_merchant($Vladimir)
	
	$CanvasLayer/UserInterface.load_ui_icons()
	$CanvasLayer/UserInterface/UniqueLeaf.margin_left = 1676
	if Global.first_entrance:
		$LeafHolders/LeafHolder.has_leaf = 0
		$LeafHolders/LeafHolder2.has_leaf = 0
	arr_enemies = arr_guardians + arr_patrollers + arr_shooters
# ------------------------------------------------------------------------------

func _process(delta):
	for i in arr_patrollers:
		i.move(i.from, i.to)
		
	for i in arr_guardians:
		i.move()
		
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

func _on_KillZone_body_entered(body):
	if body.get_collision_layer_bit(1):
		yield(get_tree().create_timer(0.25), "timeout")
		body.die()
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
