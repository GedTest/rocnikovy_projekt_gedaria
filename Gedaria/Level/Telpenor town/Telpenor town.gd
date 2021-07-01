extends Node2D


var is_yield_paused = false

#var arr_enemies = []
#
#onready var arr_patrollers = [
#	$Patroller,$Patroller2,$Patroller3,$Patroller4,$Patroller5,
#	$Patroller6,$Patroller7,$Patroller9,$Patroller10,$Patroller11,
#]
#onready var arr_guardians = [
#	$Guardian,$Guardian2,$Guardian3,$Guardian4,$Guardian5,
#]
#onready var arr_shooters = [
#	$Shooter,$Shooter2,$Shooter3,$Shooter4,
#	$Shooter5,$Shooter6,$Shooter7,$Shooter8,
#]


func _ready():
	Global.set_player_position_at_start($Vladimir, $Level_start)
	
	get_tree().set_pause(true)
	SaveLoad.load_map()
	Fullscreen.hide_elements()
# ------------------------------------------------------------------------------

func _on_LoadingTimer_timeout(): # Yield() doesn't work in ready() so an autostart timer is needed
	SaveLoad.update_current_data()
	yield(get_tree().create_timer(0.1), "timeout")
	
	get_tree().set_pause(false)
	Global.is_yield_paused = false
	$CanvasLayer/UserInterface.load_ui_icons()
	
	for leaf_holder in $LeafHolders.get_children():
		if leaf_holder.has_leaf:
			leaf_holder.show_leaf()
	
#	arr_enemies = arr_guardians + arr_patrollers + arr_shooters
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
#func _process(delta):
#	for i in arr_patrollers:
#		i.move(i.from, i.to)
#
#	for i in arr_guardians:
#		i.move()
#		if i.from != 0 or i.to != 0:
#			i.move_in_range(i.from, i.to)
# ------------------------------------------------------------------------------

func _on_KillZone_body_entered(body, sec=1.0): # Kills player if he fall into
	if body.get_collision_layer_bit(1):
		yield(get_tree().create_timer(sec), "timeout")
		body.die()
# ------------------------------------------------------------------------------

func _on_EavesdropArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.find_node("Camera").current = false
		body.is_moving = false
		print("Eavesdrop!!")
# ------------------------------------------------------------------------------

func _on_Timer_timeout():
	$Vladimir.is_moving = true
	$Vladimir/Camera.current = true
