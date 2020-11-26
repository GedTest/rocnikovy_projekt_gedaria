extends Node2D

var BOSS_Warden = preload("res://Enemy/BOSS_Warden/BOSS_Warden.tscn").instance()
var Letter = preload("res://Level/Prologue/Letter.tscn").instance()
var bBOSS = false
var bLetter = false
var bCanInteract = false
var bPickedUp = false
var bIsRake = true
var bYieldStop = false
onready var camera = $Camera2D
onready var BlockTutorial = $BlockingTutorial

func _ready():
	yield(get_tree().create_timer(3.0),"timeout")
	if $Vladimir.position.x == 150:
		$MovementTutorial.show()
		yield(get_tree().create_timer(4.0),"timeout")
		$MovementTutorial.queue_free()
# ------------------------------------------------------------------------------
func _process(delta):
	if !bIsRake:
		bIsRake = true
		if find_node("Rake"):
			$Rake.queue_free()
			$Vladimir.bAttackLearned = true
			$InteractTutorial.queue_free()
			$Tree.show()
			$Tree.play('Grow')
			$Shake.start(15,1.25,0.1)
			yield(get_tree().create_timer(1.25),"timeout")
			$Tree.queue_free()
			$UI/UserInterface.show()
		
	# INTERACT HANDLER
	if Input.is_action_just_pressed("interact"):
		if bCanInteract:
			$Rake/Label.show()
			$InteractTutorial.hide()
			# Set new animation set
		if bLetter && $Letter.bCanInteract:
			$Letter/Text.show()
			yield(get_tree().create_timer(7.0),"timeout")
			get_tree().change_scene("res://Level/Prologue/KidnapLevel.tscn")
	if bBOSS:
		# BOSS HP BAR
		$BossHPBar.show()
		$BossHPBar/Label.text = 'Warden: ' + str($BOSS_Warden.health) 
		$BossHPBar/Health.rect_size.x = 60 * $BOSS_Warden.health
		
		BOSS_Warden.Move_children()
		
		# BOSSES SECOND PHASE
		if BOSS_Warden.health <= BOSS_Warden.maxHealth / 2:
			$StaticBody2D.show()
			$StaticBody2D/CollisionShape2D.disabled = false
			$Branch/Area2D/CollisionShape2D.disabled = false
			if $Vladimir.position.x >= 1300:
				$StaticBody2D/Branch.play('Grow')
			
		# IF BOSS IS NO MORE SHOW A LETTER
		if BOSS_Warden.bIsDead && bBOSS:
			bBOSS = false
			bLetter = true
			add_child(Letter)
			Letter.position = Vector2($BOSS_Warden.position.x,$BOSS_Warden.position.y+100)
# ------------------------------------------------------------------------------
func _on_InteractTutorial_body_entered(body):
	if body.get_collision_layer_bit(1):
		bCanInteract = true
		$InteractTutorial/Label.show()
# ------------------------------------------------------------------------------
func _on_InteractTutorial_body_exited(body):
	if body.get_collision_layer_bit(1):
		bCanInteract = false
		$InteractTutorial/Label.hide()
# ------------------------------------------------------------------------------
func _on_CombatTutorial_body_entered(body):
	if body.get_collision_layer_bit(1) && bPickedUp:
		$CombatTutorial/Label.show()
# ------------------------------------------------------------------------------
func _on_CombatTutorial_body_exited(body):
	if body.get_collision_layer_bit(1):
		$CombatTutorial/Label.hide()
# ------------------------------------------------------------------------------
func _on_Scarecrow_tree_exiting():
	$CombatTutorial.queue_free()
	yield(get_tree().create_timer(0.2),"timeout")
	add_child(BOSS_Warden)
	BOSS_Warden.position = Vector2(5,910)
	yield(get_tree().create_timer(0.2),"timeout")
	bBOSS = true
	yield(get_tree().create_timer(1.5),"timeout")
	BlockTutorial.show()
	$Vladimir.bBlockingLearned = true
	yield(get_tree().create_timer(4.0),"timeout")
	BlockTutorial.queue_free()
	$Branch/Area2D2/CollisionShape2D.disabled = false
# ------------------------------------------------------------------------------
