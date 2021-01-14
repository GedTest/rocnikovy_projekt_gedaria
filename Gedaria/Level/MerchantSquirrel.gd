extends Node2D


const HEALTH_LIMIT = 20
const ATTACK_LIMIT = 10
const SPEED_LIMIT = 40 # 40%
const BASE_SPEED = 525
onready var UI = $CanvasLayer/UserInterface

var is_yield_paused = false
var arr_levels = [
	"res://Level/TestLevel.tscn","res://Level/DarkForest/DarkForest.tscn",
	"ahoj_level"
]


func _ready():
	get_tree().set_pause(true)
	SaveLoad.load_map()
	$BigTree/Leaves.hide()
# ------------------------------------------------------------------------------
	

func _on_LoadingTimer_timeout():
	SaveLoad.update_current_data()
	yield(get_tree().create_timer(0.1), "timeout")
	
	get_tree().set_pause(false)
	Global.is_yield_paused = false
	$CanvasLayer/UserInterface.load_ui_icons()
	
	var next_level = arr_levels.find(Global.last_map) + 1
	print("next level: ",arr_levels[next_level])
	$Sign.scene = arr_levels[next_level]
# ------------------------------------------------------------------------------

func _process(delta):
	pass
# ------------------------------------------------------------------------------

func _on_HealthButton_pressed():
	if $Vladimir.health >= 0 and $Vladimir.health < HEALTH_LIMIT:
		$CanvasLayer/UserInterface.update_health(1, "upgrade", \
		$Vladimir.health, $Vladimir.max_health)
		
		# replenish lives to the maximum
		$Vladimir.health = $Vladimir.max_health
		
		# now add +1 live
		$Vladimir.max_health += 1
		$Vladimir.health += 1
		
		# display new leaf on the screen
		$CanvasLayer/UserInterface.load_ui_icons()
		SaveLoad.save_to_file(4)
		
	print($Vladimir.health)
# ------------------------------------------------------------------------------

func _on_AttackButton_pressed():
	if $Vladimir.damage < ATTACK_LIMIT:
		$Vladimir.damage += 1
		SaveLoad.save_to_file(4)
	print($Vladimir.damage)
# ------------------------------------------------------------------------------

func _on_SpeedButton_pressed():
	if $Vladimir.speed <= BASE_SPEED + BASE_SPEED*SPEED_LIMIT/100:
		print("before: ",$Vladimir.speed," then: ",$Vladimir.speed * 0.05)
		$Vladimir.speed += $Vladimir.speed * 0.05
		SaveLoad.save_to_file(4)
