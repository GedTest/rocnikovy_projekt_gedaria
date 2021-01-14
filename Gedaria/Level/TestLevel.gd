extends Node2D


signal enemy_health_changed

var is_done_once = true
var is_yield_paused = false

onready var arr_patrollers = [
	$Patroller,$Patroller2,$Patroller3,$Patroller4,$Patroller5,
	$Patroller6,$Patroller7,$Patroller9,$Patroller10,$Patroller11,
]
onready var arr_guardians = [
	$Guardian,$Guardian2,$Guardian3,$Guardian4,$Guardian5,
]


func _ready():
	get_tree().set_pause(true)
	SaveLoad.load_map()
	
	connect("enemy_health_changed", $FallingTree, "on_enemy_health_changed")
	
#	$Vladimir.has_learned_attack = true
	$Vladimir.has_learned_heavy_attack = false
#	$Vladimir.has_learned_blocking = true
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
	
	for leaf_holder in $LeafHolders.get_children():
		if leaf_holder.has_leaf:
			leaf_holder.show_leaf()
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
	
	if find_node("Patroller5"):
		if find_node("Patroller5").health <= 2 and is_done_once:
			is_done_once = false
			emit_signal("enemy_health_changed")
			
			$Vladimir.position = Vector2(6980, 5805)
			$Vladimir.is_moving = false
# ------------------------------------------------------------------------------

func _on_KillZone_body_entered(body): # Kills player if he fall into
	if body.get_collision_layer_bit(1):
		yield(get_tree().create_timer(0.5), "timeout")
		$Vladimir.die()
# ------------------------------------------------------------------------------

func _on_AmbushArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		$Patroller3.position = Vector2(3500, 4787)
		$Patroller4.position = Vector2(3580, 4787)
		$Patroller5.position = Vector2(7534, 4959)
# ------------------------------------------------------------------------------

func _on_RakingLearn_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.has_learned_raking = true
# ------------------------------------------------------------------------------

func _on_HeavyAttackLearn_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.has_learned_heavy_attack = true
		body.heavy_attack_counter = 4
