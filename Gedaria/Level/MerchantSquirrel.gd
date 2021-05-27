extends Node2D


const HEALTH_LIMIT = 20
const DAMAGE_LIMIT = 10
const SPEED_LIMIT = 25 # 25%
const BASE_SPEED = 525
onready var UI = $CanvasLayer/UserInterface

var is_yield_paused = false
var arr_levels = [
	"res://Level/TestLevel.tscn","res://Level/DarkForest/DarkForest.tscn",
	"res://Level/CaveEntrance/CaveEntrance.tscn","res://Level/CultInCave/CultInCave.tscn",
]
var damage_upgrade_counter = 1
var health_upgrade_counter = 1
var speed_upgrade_counter = 1

func _ready():
	get_tree().set_pause(true)
	SaveLoad.load_map()
	$BigTree/Leaf_node.hide()
# ------------------------------------------------------------------------------
	
func _on_LoadingTimer_timeout():
	$Vladimir.position = $Level_start.position
	SaveLoad.update_current_data()
	yield(get_tree().create_timer(0.1), "timeout")
	
	get_tree().set_pause(false)
	Global.is_yield_paused = false
	Global.is_pausable = false
	$CanvasLayer/UserInterface.load_ui_icons()
	
	
	print("next level: ",Global.get_next_level())
	$Sign.scene = Global.get_next_level()
	
	var vladimir_data = Global.vladimir_data()
	print("vladimir_data: ", vladimir_data)
	print("has data? ",SaveLoad.slots["slot_4"].has(vladimir_data))
	if Global.vladimir_has_previous_data():
		$Vladimir.set_values(SaveLoad.slots["slot_4"][vladimir_data])
# ------------------------------------------------------------------------------
#	var sum = 0
#	for i in range(1,9):
#		var HP = int(10.5+pow(1.5, i))
#		var DMG = int(10.5+pow(1.5, i))
#		var MS = int(9.25+pow(1.4, i))
#		print("HP, DMG: ",HP," ", DMG)
#		print("MS: ",MS)
#		sum += (HP + DMG + MS)
#	print("SUM: ",sum)
func _process(delta):
	pass
# ------------------------------------------------------------------------------

func _on_HealthButton_pressed():
	var cost = 3+int(pow(1.4, health_upgrade_counter))
	if $Vladimir.health < HEALTH_LIMIT:
		if $Vladimir.acorn_counter >= cost:
			$Vladimir.acorn_counter -= cost
			health_upgrade_counter += 1
		
			$CanvasLayer/UserInterface.update_health(1, "upgrade", \
			$Vladimir.health, $Vladimir.max_health)
			
			# replenish lives to the maximum
			$Vladimir.health = $Vladimir.max_health
			
			# now add +1 live
			$Vladimir.max_health += 1
			$Vladimir.health += 1
			
			# display new leaf on the screen
			$CanvasLayer/UserInterface.load_ui_icons()
			print("UPGRADE HP: ",$Vladimir.health," OF MAX: ",$Vladimir.max_health)
			SaveLoad.save_to_file(4)
# ------------------------------------------------------------------------------

func _on_AttackButton_pressed():
	var cost = 3+int(pow(1.4, health_upgrade_counter))
	
	if $Vladimir.damage < DAMAGE_LIMIT:
		if $Vladimir.acorn_counter >= cost:
			$Vladimir.acorn_counter -= cost
			damage_upgrade_counter += 1
		
			$Vladimir.damage += 1
			SaveLoad.save_to_file(4)
	print("UPGRADE DMG: ",$Vladimir.damage)
# ------------------------------------------------------------------------------

func _on_SpeedButton_pressed():
	var cost = 2+int(pow(1.4, health_upgrade_counter))
	
	if $Vladimir.speed <= BASE_SPEED + BASE_SPEED*SPEED_LIMIT/100:
		if $Vladimir.acorn_counter >= cost:
			$Vladimir.acorn_counter -= cost
			speed_upgrade_counter += 1
		
			print("before: ",$Vladimir.speed," + ",$Vladimir.speed * 0.05)
			$Vladimir.speed += $Vladimir.speed * 0.05
			SaveLoad.save_to_file(4)
			print("UPGRADE SPEED: ",$Vladimir.speed)
