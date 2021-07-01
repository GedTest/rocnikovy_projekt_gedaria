extends Control


var timer = null
var is_yield_paused = false
var current_health = 12
var max_health = 0
var saved_health = 0
var acorn_counter = 0
var pebble_counter = 0
var heavy_attack_counter = 0

onready var arr_max_health = [
	$leaves/FallingLeaves1,$leaves/FallingLeaves2,
	$leaves/FallingLeaves3,$leaves/FallingLeaves4,
	$leaves/FallingLeaves5,$leaves/FallingLeaves6,
	$leaves/FallingLeaves7,$leaves/FallingLeaves8,
	$leaves/FallingLeaves9,$leaves/FallingLeaves10,
	$leaves/FallingLeaves11,$leaves/FallingLeaves12,
	$leaves/FallingLeaves13,$leaves/FallingLeaves14,
	$leaves/FallingLeaves15,$leaves/FallingLeaves16,
	$leaves/FallingLeaves17,$leaves/FallingLeaves18,
	$leaves/FallingLeaves19,$leaves/FallingLeaves20,
]
onready var arr_pebbles = [
	$Pebbles/Pebble1,$Pebbles/Pebble2,$Pebbles/Pebble3,
	$Pebbles/Pebble4,$Pebbles/Pebble5,
]


func _ready():
	if Global.level_root().filename == "res://Level/DarkForest/Dark forest.tscn":
		$Blueberries.show()
		$BlueberryCounter.show()
	timer = get_tree().create_timer(0.0)
# ------------------------------------------------------------------------------

func _process(delta):
	var vladimir = Global.level_root().find_node('Vladimir')
	if vladimir:
		acorn_counter = vladimir.acorn_counter
		$AcornCounter.text = str(acorn_counter) + "x"
		
		max_health = vladimir.max_health
		current_health = vladimir.health
		
		pebble_counter = vladimir.pebble_counter
		
		heavy_attack_counter = vladimir.heavy_attack_counter
		$UniqueLeaf.visible = true if heavy_attack_counter > 0 else false
		$UniqueLeafCounter.visible = $UniqueLeaf.visible
		$UniqueLeafCounter.text = str(int(heavy_attack_counter / 4)) + "x"
		$UniqueLeaf.value = int(heavy_attack_counter) % 4
		
		$Slingshot.visible = vladimir.has_slingshot
		is_yield_paused = Global.level_root().is_yield_paused
# ------------------------------------------------------------------------------

func update_health(var value, var condition : String, var current_health, \
				   var max_health = 12):
	match condition:
		"minus":
		# warning-ignore:unused_variable
			if current_health >= 0:
				for i in range(value):
					current_health -= 1
					
					arr_max_health[current_health].find_node('Leaf').hide()
					arr_max_health[current_health].emitting = true
					arr_max_health[current_health].one_shot = false
					
					arr_max_health[current_health].one_shot = true
		"plus":
			if current_health >= 0 and current_health < max_health:
				for i in range(value):
					arr_max_health[current_health].find_node('Leaf').show()
					current_health += 1
		"upgrade":
				var next_life = $leaves.get_children()[max_health]
				arr_max_health.append(next_life)
				arr_max_health[max_health].show()
				arr_max_health[max_health].find_node('Leaf').show()
# ------------------------------------------------------------------------------

func update_pebbles(var num, var condition : String, var pebble_counter):
	match condition:
		"minus":
			if pebble_counter >= 0:
				for pebble in range(num):
					arr_pebbles[pebble_counter].hide()
					pebble_counter -= 1
		
		"plus":
			if pebble_counter >= 0 and pebble_counter <= 5:
				for pebble in range(num):
					arr_pebbles[pebble_counter-1].show()
					pebble_counter += 1
# ------------------------------------------------------------------------------

func save():
	var saved_data = {
		"saved_health":current_health,
		"max_health":max_health,
		"acorn_counter":acorn_counter
	}
	return saved_data
# ------------------------------------------------------------------------------

func load_ui_icons():
	yield(get_tree().create_timer(0.25), "timeout")
	for leaf_holder in arr_max_health:
		leaf_holder.find_node('Leaf').hide()
	
	for leaf_holder in range(current_health):
		arr_max_health[leaf_holder].find_node('Leaf').show()
		arr_max_health[leaf_holder].show()

	for pebble in arr_pebbles:
		pebble.hide()
	for i in range(pebble_counter):
		arr_pebbles[i].show()
		
	if acorn_counter > 0:
		$AcornCounter.show()
		$Acorn.show()
	
	$BlueberryCounter.text = str(Global.blue_berries) + "/5"
