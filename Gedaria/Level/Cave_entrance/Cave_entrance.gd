extends Node2D


var PebblePath = preload("res://Vladimir/PebbleOnGround.tscn")

onready var arr_bats = [
	$Bat,$Bat2,$Bat3,$Bat4,$Bat5,
	$Bat6,$Bat7,$Bat8,$Bat9,$Bat10,
	$Bat11,$Bat12,$Bat13,$Bat14,$Bat15,
	$Bat16,$Bat17,$Bat18,$Bat19,$Bat20,
	$Bat21,
]

var is_yield_paused = false
var has_key = false
var is_interactable = false


func _ready():
	#Global.set_player_position_at_start($Vladimir, $Level_start)

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

	#if SaveLoad.slots["slot_4"][vladimir_data]:
	#	$Vladimir.set_values(SaveLoad.slots["slot_4"][vladimir_data])

	$CanvasLayer/UserInterface.load_ui_icons()
# ------------------------------------------------------------------------------

func _process(delta):
	for bat in arr_bats:
		bat.move(bat.from, bat.to)
		
	if Input.is_action_just_pressed("interact") and is_interactable:
		$Bars.queue_free()
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
