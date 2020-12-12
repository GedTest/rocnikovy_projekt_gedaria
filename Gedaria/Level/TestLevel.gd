extends Node2D


var PebblePath = preload("res://Vladimir/PebbleOnGround.tscn")

var is_done_once = true
var is_yield_paused = false

onready var arr_patrollers = [
	$Patroller,$Patroller2,$Patroller3,$Patroller4,$Patroller5,
	$Patroller6,$Patroller7,$Patroller9,$Patroller10,
]
onready var arr_guardians = [
	$Guardian,$Guardian2,$Guardian3,$Guardian4,$Guardian5,
]


func _ready():
	for node in $Leaves.get_children():
		node.add_to_group("persistant")
		
	get_tree().set_pause(true)
	SaveLoad.load_map()
	
	#for child in get_tree().get_nodes_in_group("persistant"):
	#	print(child.name)
	$Vladimir.has_learned_attack = true
	$Vladimir.has_learned_heavy_attack = false
	$Vladimir.has_learned_blocking = true
	$Vladimir.has_learned_raking = true
	
	$Vladimir/Camera.current = true
# ------------------------------------------------------------------------------

func _on_LoadingTimer_timeout(): # Yield() doesn't work in ready() so an autostart timer is needed
	SaveLoad.update_current_data()
	yield(get_tree().create_timer(0.1), "timeout")
	
	get_tree().set_pause(false)
	Global.is_yield_paused = false
	Global.is_pausable = true
	$CanvasLayer/UserInterface.load_ui_icons()
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _process(delta):
	for i in arr_patrollers:
		i.move(i.from, i.to)
		
	for i in arr_guardians:
		i.move()

	if $Patroller8.is_focused:
		$Patroller8.move($Patroller8.from, $Patroller8.to)
		
	if $PilesOfLeaves/PileOfLeaves1.is_complete:
		$Wind.position = Vector2(35500, 7000)
	
# ------------------------------------------------------------------------------

func _on_SaveButton_pressed(): # Show save slots and save game
	$Slots/SaveButtons.show()
	$Slots/Close.show()
	
	$CanvasLayer/SaveButton.release_focus()
# ------------------------------------------------------------------------------

func _on_LoadButton_pressed(): # Show save slots and load game
	$Slots/LoadButtons.show()
	$Slots/Close.show()
	
	$CanvasLayer/LoadButton.release_focus()
# ------------------------------------------------------------------------------

func _on_RestartButton_pressed(): # Restart the level from beginning
	is_yield_paused = true
	$CanvasLayer/UserInterface.is_yield_paused = is_yield_paused
	get_tree().set_pause(true)
	yield(get_tree().create_timer(5.0), "timeout")
	
	SaveLoad.restart_level()
# ------------------------------------------------------------------------------

func _on_MainMenuButton_pressed(): # Go to Main Menu
	is_yield_paused = true
	$CanvasLayer/UserInterface.is_yield_paused = is_yield_paused
	get_tree().set_pause(true)
	yield(get_tree().create_timer(7.0), "timeout")
	
	get_tree().change_scene("res://Level/MainMenu/MainMenu.tscn")
# ------------------------------------------------------------------------------

func _on_KillZone_body_entered(body): # Kills player if he fall into
	if body.get_collision_layer_bit(1):
		yield(get_tree().create_timer(0.5), "timeout")
		$Vladimir.die()
# ------------------------------------------------------------------------------

func _on_SlingshotButton_pressed():
	$Vladimir.has_slingshot = !$Vladimir.has_slingshot
	$CanvasLayer/SlingshotButton.release_focus()
# ------------------------------------------------------------------------------

func _on_added_pebble(old_pebble_position):
	var new_pebble = PebblePath.instance()
	$Pebbles.call_deferred("add_child", new_pebble)
	new_pebble.position = old_pebble_position
