extends Node2D


onready var arr_bats = [
	$Bat1,$Bat2,$Bat3,$Bat4,$Bat5,
	$Bat6,$Bat7,$Bat8,$Bat9,$Bat10,
	$Bat11,
]

var is_yield_paused = false


func _ready():
	#Global.set_player_position_at_start($Vladimir, $Level_start)
	Global.is_first_entrance(self.filename)
	
	get_tree().set_pause(true)
	SaveLoad.load_map()
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
	
	Global.update_data_from_merchant($Vladimir)

	$CanvasLayer/UserInterface.load_ui_icons()
# ------------------------------------------------------------------------------

func _process(delta):
	for bat in arr_bats:
		bat.move(bat.from, bat.to)
# ------------------------------------------------------------------------------

func _on_KillZone_body_entered(body):
	if body.get_collision_layer_bit(1):
		yield(get_tree().create_timer(0.5), "timeout")
		body.die()
# ------------------------------------------------------------------------------
