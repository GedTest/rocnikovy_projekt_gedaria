extends Level


const REWARD_SFX = preload("res://sfx/reward.wav")
const INTERACTION_SFX = preload("res://sfx/interaction.wav")

var is_interactable = false

onready var arr_bats = [
	$Bat,$Bat2,$Bat3,$Bat4,$Bat5,
	$Bat6,$Bat7,$Bat8,$Bat9,$Bat10,
]
onready var leaf_holders_to_free = [
	$LeafHolders/LeafHolder91,$LeafHolders/LeafHolder84,
	$LeafHolders/LeafHolder86,$LeafHolders/LeafHolder88,
	]


func _on_LoadingTimer_timeout():
	._on_LoadingTimer_timeout()
	Global.update_data_from_merchant($Vladimir)
	acorn_counter = 25
	unique_leaves_counter = 1
	
	$PilesOfLeaves/PileOfLeavesWide/BounceArea.connect("body_entered", self, "_on_bounce")
# ------------------------------------------------------------------------------

func _process(delta):
	for bat in arr_bats:
		bat.move(bat.from, bat.to)
		
	if Input.is_action_just_pressed("interact") and is_interactable:
		#play animation of opening bars
		$AnimationPlayer.play("BARS_UP")
		$Winds/Wind.disable_wind()
		$Winds/Wind20.disable_wind()
		$Winds/Wind22.disable_wind()
		Global.has_key = false
		$CanvasLayer/UserInterface/Key.hide()
		
	if $PilesOfLeaves/PileOf4Leaves3.is_complete:
		$Winds/Wind19.disable_wind()
		
	if $LeafHolders/LeafHolder13.has_leaf:
		$Winds/Wind14.disable_wind()
		if $LeafHolders/LeafHolder12.has_leaf:
			$Winds/Wind4.disable_wind()
			$Winds/Wind15.disable_wind()
			
	if $LeafHolders.find_node("LeafHolder95"):
		$LeafHolders/LeafHolder95.set_collision_layer_bit(0, false)
		$LeafHolders/LeafHolder95.set_collision_layer_bit(3, false)
		$LeafHolders/LeafHolder95.set_collision_mask_bit(3, false)
# ------------------------------------------------------------------------------

func _on_Bars_body_entered(body):
	if body.get_collision_layer_bit(1) and Global.has_key:
		is_interactable = true
# ------------------------------------------------------------------------------

func _on_Bars_body_exited(body):
	if body.get_collision_layer_bit(1):
		is_interactable = false
# ------------------------------------------------------------------------------

func _on_Key_body_entered(body):
	if body.get_collision_layer_bit(1):
		AudioManager.play_sfx(REWARD_SFX, 0, 0, -9)
		Global.has_key = true
		$TutorialSign6.show()
		$Key.queue_free()
# ------------------------------------------------------------------------------

func _on_LeafArea_body_entered(body):
	if body.get_collision_layer_bit(3):
		Global.leaves_in_cave_counter += 1
		var counter = $CanvasLayer/UserInterface/LeavesInCave/Counter
		counter.text = str(Global.leaves_in_cave_counter)+"/9"
		
		if Global.leaves_in_cave_counter == 9:
			SaveLoad.delete_actor($KillZones/KillZone3)
			$PilesOfLeaves/PileOfLeavesWide2.modulate = Color(1, 1, 1, 1)
# ------------------------------------------------------------------------------

func _on_Wind_body_entered(body):
	if body.get_collision_layer_bit(1):
		$Winds/Wind8.scale.y = 1.5
		$Winds/Wind8.impulse.x = -2000
# ------------------------------------------------------------------------------

func _on_bounce(body):
	if body.get_collision_layer_bit(1):
		$PilesOfLeaves/PileOfLeavesWide/AnimatedSprite.frame = 0
		$PilesOfLeaves/PileOfLeavesWide/AnimatedSprite.play("bounce")
# ------------------------------------------------------------------------------

func _on_FreeLeavesArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		for leaf_holder in leaf_holders_to_free:
			if is_instance_valid(leaf_holder):
				if leaf_holder.has_leaf:
					leaf_holder.spawn_leaf()
# ------------------------------------------------------------------------------

func _on_LeavesInCave_body_entered(body):
	if body.get_collision_layer_bit(1):
		$LeavesInCave/CollisionShape2D.set_deferred("disabled", true)
		$CanvasLayer/UserInterface/LeavesInCave.show()
		$AnimationPlayer.play("DANGER")
		$Vladimir.stop_moving_during_cutsene(5.0)
# ------------------------------------------------------------------------------

func _on_TwoLeafTutorial_body_entered(body, tutorial_sign):
	if body.get_collision_layer_bit(1):
		get_node(tutorial_sign).find_node("Sprite").show()
# ------------------------------------------------------------------------------

func _on_TwoLeafTutorial_body_exited(body, tutorial_sign):
	if body.get_collision_layer_bit(1):
		get_node(tutorial_sign).find_node("Sprite").hide()
# ------------------------------------------------------------------------------

func _on_FreeObjectsArea_body_entered(body):
	for node in get_tree().get_nodes_in_group("free"):
		if is_instance_valid(node):
			SaveLoad.delete_actor(node)
	$FreeLeavesArea/CollisionShape2D.set_deferred("disabled", true)
