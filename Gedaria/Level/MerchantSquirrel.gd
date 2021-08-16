extends Node2D


const HEALTH_LIMIT = 20
const DAMAGE_LIMIT = 10
const SPEED_LIMIT = 25 # 25%
const BASE_SPEED = 480
const HEAVY_ATTACK_LIMIT = 7
onready var UI = $CanvasLayer/UserInterface

var is_yield_paused = false
var can_interact = false

var arr_levels = [
	"res://Level/InTheWood/In the wood.tscn","res://Level/DarkForest/Dark forest.tscn",
	"res://Level/CaveEntrance/Cave entrance.tscn","res://Level/CultInCave/Mine shaft.tscn",
]
var damage_upgrade_counter = 1
var health_upgrade_counter = 1
var speed_upgrade_counter = 1

onready var arr_texts = {
	"price":$CanvasLayer/HealthButton/Label,
	"heavyattack":$CanvasLayer/HeavyAttackButton,
	"health":$CanvasLayer/HealthButton,
	"damage:":$CanvasLayer/AttackButton,
	"speed":$CanvasLayer/SpeedButton,
	}
onready var arr_buttons = [
	$CanvasLayer/HealthButton,$CanvasLayer/AttackButton,
	$CanvasLayer/HeavyAttackButton,$CanvasLayer/SpeedButton,
	]


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().set_pause(true)
	SaveLoad.load_map()
	
	$Tree/Area2D/Tween.interpolate_property($Tree/Squirrel, "position", Vector2(-31, 323),\
								Vector2(-31, 168), 0.4,\
								Tween.TRANS_BACK, Tween.EASE_OUT)
# ------------------------------------------------------------------------------
	
func _on_LoadingTimer_timeout():
	$Vladimir.position = $LevelStart.position
	SaveLoad.update_current_data()
	yield(get_tree().create_timer(0.1), "timeout")
	
	get_tree().set_pause(false)
	Global.is_yield_paused = false
	Global.is_pausable = false
	Fullscreen.hide_elements()
	$CanvasLayer/UserInterface.load_ui_icons()
	
	$Sign.scene = Global.get_next_level()
	
	var vladimir_data = Global.vladimir_data()
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
	if can_interact and Input.is_action_just_pressed("interact"):
		for button in get_tree().get_nodes_in_group("buy_btn"):
			button.visible = not button.visible
		$Vladimir.is_moving = not $Vladimir.is_moving
		$Vladimir.velocity = Vector2.ZERO
		$Vladimir.state_machine.travel("IDLE")
	
	for button in arr_buttons:
		if button.is_hovered():
			$CanvasLayer/UpgradeLabel.show()
			var POSITIONS = [
				Vector2(1485, 350),Vector2(1485, 448),
				Vector2(1485, 544),Vector2(1485, 628),
			]
			$CanvasLayer/UpgradeLabel.rect_position = POSITIONS[arr_buttons.find(button)]
			if button.name == "SpeedButton":
				$CanvasLayer/UpgradeLabel.text = "+5%"
			else:
				$CanvasLayer/UpgradeLabel.text = "+1"
				
	if not (arr_buttons[0].is_hovered() or arr_buttons[1].is_hovered() \
		or arr_buttons[2].is_hovered() or arr_buttons[3].is_hovered()):
		$CanvasLayer/UpgradeLabel.hide()
# ------------------------------------------------------------------------------

func _on_HealthButton_pressed():
#	var cost = 3+int(pow(1.4, health_upgrade_counter))
	var cost = 12
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
			$CanvasLayer/HealthButton/Counter.text = str($Vladimir.health)+"/"+str(HEALTH_LIMIT)
			SaveLoad.save_to_file(4)
# ------------------------------------------------------------------------------

func _on_AttackButton_pressed():
#	var cost = 3+int(pow(1.4, health_upgrade_counter))
	var cost = 16
	if $Vladimir.damage < DAMAGE_LIMIT:
		if $Vladimir.acorn_counter >= cost:
			$Vladimir.acorn_counter -= cost
			damage_upgrade_counter += 1
		
			$Vladimir.damage += 1
			
			$CanvasLayer/AttackButton/Counter.text = str($Vladimir.damage)+"/"+str(DAMAGE_LIMIT)
			SaveLoad.save_to_file(4)
# ------------------------------------------------------------------------------

func _on_SpeedButton_pressed():
#	var cost = 2+int(pow(1.4, health_upgrade_counter))
	var cost = 8
	if $Vladimir.speed <= BASE_SPEED + BASE_SPEED*SPEED_LIMIT/100:
		if $Vladimir.acorn_counter >= cost:
			$Vladimir.acorn_counter -= cost
			speed_upgrade_counter += 1
		
			$Vladimir.speed += $Vladimir.speed * 0.05
			
			$CanvasLayer/SpeedButton/Counter.text = str((speed_upgrade_counter-1)*5)+"%/"+str(SPEED_LIMIT)+"%"
			SaveLoad.save_to_file(4)
# ------------------------------------------------------------------------------

func _on_HeavyAttackButton_pressed():
	var cost = 30
	if $Vladimir.heavy_attack_increment < HEAVY_ATTACK_LIMIT:
		if $Vladimir.acorn_counter >= cost:
			$Vladimir.acorn_counter -= cost
		
			$Vladimir.heavy_attack_increment += 1
			
			$CanvasLayer/HeavyAttackButton/Counter.text = str($Vladimir.heavy_attack_increment)+"/"+str(HEAVY_ATTACK_LIMIT)
			SaveLoad.save_to_file(4)
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		Languages.translate(arr_texts, Global.prefered_language)
		var translated_text = $CanvasLayer/HealthButton/Label.text
		$CanvasLayer/HealthButton/Label.text += "12"
		$CanvasLayer/AttackButton/Label.text = translated_text + "16"
		$CanvasLayer/SpeedButton/Label.text = translated_text + "8"
		$CanvasLayer/HeavyAttackButton/Label.text = translated_text + "30"
		can_interact = true
		$Tree/Area2D/Tween.start()
		$TutorialSign.wrap_intreaction_text($Tree/Area2D/Icon/Label)
		$Tree/Area2D/Icon.show()
# ------------------------------------------------------------------------------

func _on_Area2D_body_exited(body):
	if body.get_collision_layer_bit(1):
		can_interact = false
		$Vladimir.is_moving = true
		$Tree/Area2D/Icon.hide()
		for button in get_tree().get_nodes_in_group("buy_btn"):
			button.hide()

