extends Node2D


const PebblePath = preload("res://Vladimir/PebbleOnGround.tscn")


var is_yield_paused = false
var has_key = false
var is_interactable = false

var leaf_counter = 0

onready var arr_bats = [
	$Bat,$Bat2,$Bat3,$Bat4,$Bat5,
	$Bat6,$Bat7,$Bat8,$Bat9,$Bat10,
]

func _ready():
#	Global.set_player_position_at_start($Vladimir, $Level_start)
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
	$PileOfLeaves/PileOfLeavesWide/BounceArea.connect("body_entered", self, "_on_bounce")
# ------------------------------------------------------------------------------

func _process(delta):
	for bat in arr_bats:
		bat.move(bat.from, bat.to)
		
	if Input.is_action_just_pressed("interact") and is_interactable:
		$Bars.queue_free()
		
	if $PileOfLeaves/PileOf4Leaves3.is_complete:
		$Winds/Wind19.disable_wind()
		
	if $LeafHolders/LeafHolder13.has_leaf:
		$Winds/Wind14.disable_wind()
		if $LeafHolders/LeafHolder12.has_leaf:
			$Winds/Wind4.disable_wind()
			$Winds/Wind15.disable_wind()
# ------------------------------------------------------------------------------

func _on_CaveTeleport_body_entered(body, next_position):
	if body.get_collision_layer_bit(1):
		body.position = next_position
# ------------------------------------------------------------------------------

func _on_KillZone_body_entered(body, sec):
	if body.get_collision_layer_bit(1):
		yield(get_tree().create_timer(sec), "timeout")
		body.die()
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1) and has_key:
		$Bars/TextBackground.show()
		is_interactable = true
# ------------------------------------------------------------------------------

func _on_Area2D_body_exited(body):
	if body.get_collision_layer_bit(1):
		$Bars/TextBackground.hide()
		is_interactable = false


func _on_Key_body_entered(body):
	if body.get_collision_layer_bit(1):
		has_key = true


func _on_LeafArea_body_entered(body):
	if body.get_collision_layer_bit(3):
		leaf_counter += 1
		print(leaf_counter)
		
		if leaf_counter == 9:
			SaveLoad.delete_actor($KillZone3)
			$PileOfLeaves/PileOfLeavesWide2.show()


func _on_Wind_body_entered(body):
	if body.get_collision_layer_bit(1):
		$Winds/Wind8.scale.y = 1.5
		$Winds/Wind8.impulse.x = -2000
		print($Winds/Wind8.impulse)

func _on_bounce(body):
	if body.get_collision_layer_bit(1):
		$PileOfLeaves/PileOfLeavesWide/AnimatedSprite.frame = 0
		$PileOfLeaves/PileOfLeavesWide/AnimatedSprite.play("bounce")
