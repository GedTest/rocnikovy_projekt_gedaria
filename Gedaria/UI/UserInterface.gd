extends Control

var timer = null
var bYieldStop = false
var currentHealth = 12
var pebbleCounter = 0
var maxHealth = 0
var savedHealth = 0
var acornCounter = 0
onready var arrMaxHealth = [$leaves/FallingLeaves1,$leaves/FallingLeaves2,
							$leaves/FallingLeaves3,$leaves/FallingLeaves4,
							$leaves/FallingLeaves5,$leaves/FallingLeaves6,
							$leaves/FallingLeaves7,$leaves/FallingLeaves8,
							$leaves/FallingLeaves9,$leaves/FallingLeaves10,
							$leaves/FallingLeaves11,$leaves/FallingLeaves12]
onready var arrPebbles = [$Pebbles/Pebble1,$Pebbles/Pebble2,$Pebbles/Pebble3,
						$Pebbles/Pebble4,$Pebbles/Pebble5]

func _ready():
	timer = get_tree().create_timer(0.0)
# ------------------------------------------------------------------------------
func _process(delta):
	#var vladimir = get_parent().get_parent().find_node('Vladimir')
	
	#acornCounter = vladimir.acornCounter
	#$AcornCounter.text = str(acornCounter) + "x"
	
	#maxHealth = vladimir.maxHealth
	#currentHealth = vladimir.health
	
	#pebbleCounter = vladimir.pebbleCounter
	
	#$Slingshot.visible = vladimir.bHasSlingshot
	bYieldStop = get_parent().get_parent().bYieldStop
# ------------------------------------------------------------------------------
func UpdateHealth(var value, var condition : String, var currentHealth,var maxHealth = 12):
	match condition:
		"minus":
		# warning-ignore:unused_variable
			if currentHealth >= 0:
				for i in range(value):
					currentHealth -= 1
					
					arrMaxHealth[currentHealth].find_node('Leaf').hide()
					arrMaxHealth[currentHealth].emitting = true
					arrMaxHealth[currentHealth].one_shot = false
					
					if timer.time_left <= 0.0:
						timer = get_tree().create_timer(0.1)
						if !bYieldStop:
							yield(timer,"timeout")
							arrMaxHealth[currentHealth].one_shot = true
		
		"plus":
			if currentHealth >= 0 && currentHealth < maxHealth:
				for i in range(value):
					arrMaxHealth[currentHealth].find_node('Leaf').show()
					currentHealth += 1
# ------------------------------------------------------------------------------
func UpdatePebbles(var num, var condition : String, var pebbleCounter):
	match condition:
		"minus":
			if pebbleCounter >= 0:
			# warning-ignore:unused_variable
				for pebble in range(num):
					arrPebbles[pebbleCounter].hide()
					pebbleCounter -= 1
		
		"plus":
			if pebbleCounter >= 0 && pebbleCounter <= 5:
			# warning-ignore:unused_variable
				for pebble in range(num):
					arrPebbles[pebbleCounter-1].show()
					pebbleCounter += 1
# ------------------------------------------------------------------------------
#func Save():
#	var savedData = {
#		"UI":"UI",
#		#"savedHealth":currentHealth,
#		#"maxHealth":maxHealth,
#		#"acornCounter":acornCounter
#	}
#	return savedData
# ------------------------------------------------------------------------------
func LoadUiIcons():
	yield(get_tree().create_timer(0.25),"timeout")
	for leaf in arrMaxHealth:
		leaf.find_node('Leaf').hide()
	
	for leaf in range(currentHealth):
		arrMaxHealth[leaf].find_node('Leaf').show()

	for pebble in arrPebbles:
		pebble.hide()
	for i in range(pebbleCounter):
		arrPebbles[i].show()
