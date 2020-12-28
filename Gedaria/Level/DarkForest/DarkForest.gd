extends Node2D

var PebblePath = preload("res://Vladimir/PebbleOnGround.tscn")

onready var arr_patrollers = [
	$Patroller,$Patroller2,$Patroller3,$Patroller4,$Patroller5,
	$Patroller6,$Patroller7,$Patroller8,$Patroller9,$Patroller10,
]
onready var arr_guardians = [
	$Guardian,$Guardian2,$Guardian3,$Guardian4,
]

var is_yield_paused = false


func _ready():
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
	$CanvasLayer/UserInterface.load_ui_icons()
	
	for leaf_holder in $LeafHolders.get_children():
		if leaf_holder.has_leaf:
			leaf_holder.add_leaf()
# ------------------------------------------------------------------------------

func _process(delta):
	for i in arr_patrollers:
		i.move(i.from, i.to)
		
	for i in arr_guardians:
		i.move()
# ------------------------------------------------------------------------------

func _on_Mushroom_tree_exited():
	$InvisibleWall.queue_free()
# ------------------------------------------------------------------------------

func _on_KillZone_body_entered(body):
	if body.get_collision_layer_bit(1):
		yield(get_tree().create_timer(0.25), "timeout")
		$Vladimir.die()
# ------------------------------------------------------------------------------

func _on_added_pebble(old_pebble_position):
	var new_pebble = PebblePath.instance()
	$Pebbles.call_deferred("add_child", new_pebble)
	new_pebble.position = old_pebble_position
