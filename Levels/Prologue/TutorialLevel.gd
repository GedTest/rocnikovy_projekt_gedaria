extends Node2D

var BOSS_Warden = preload("res://Enemy/BOSS_Warden/BOSS_Warden.tscn").instance()
var Letter = preload("res://Level/Prologue/Letter.tscn").instance()
var bBOSS = false
var bLetter = false
var bCanInteract = false
var bPickedUp = false

func _ready():
	$Vladimir/AnimatedSprite/WeaponHitbox/CollisionShape2D.disabled = true
	yield(get_tree().create_timer(3),"timeout")
	if $Vladimir.position.x == 150:
		$MovementTutorial.show()
		yield(get_tree().create_timer(4),"timeout")
		$MovementTutorial.queue_free()
# ------------------------------------------------------------------------------
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if bCanInteract:
			$Rake.hide()
			$InteractTutorial.queue_free()
			bPickedUp = true
			$Vladimir/AnimatedSprite/WeaponHitbox/CollisionShape2D.disabled = false
			# Set new animation set
		if bLetter && $Letter.bCanInteract:
			$Letter/Text.show()
			yield(get_tree().create_timer(5.0),"timeout")
			$Letter/Text.hide()
	if bBOSS:
		$BossHPBar.show()
		$BossHPBar/Label.text = 'Warden: ' + str($BOSS_Warden.health) 
		$BossHPBar/Health.rect_size.x = 10 * $BOSS_Warden.health
		$BOSS_Warden.Move_children()
		yield(get_tree().create_timer(2.0),"timeout")
		$BlockingTutorial.show()
		yield(get_tree().create_timer(4.0),"timeout")
		$BlockingTutorial.text = ""
		if $BOSS_Warden.bIsDead && bBOSS:
			bBOSS = false
			bLetter = true
			add_child(Letter)
			$Letter.position = $BOSS_Warden.position
		
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
	add_child(BOSS_Warden)
	BOSS_Warden.position = Vector2(10,640)
	yield(get_tree().create_timer(0.5),"timeout")
	bBOSS = true
	$Button.show()
# ------------------------------------------------------------------------------
func _on_Button_pressed():
	get_tree().change_scene("res://Level/TestLevel.tscn")
