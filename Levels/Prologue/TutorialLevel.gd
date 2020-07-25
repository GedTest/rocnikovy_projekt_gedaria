extends Node2D

var BOSS_Warden = preload("res://Enemy/BOSS_Warden/BOSS_Warden.tscn").instance()
var Letter = preload("res://Level/Prologue/Letter.tscn").instance()
var bBOSS = false
var bLetter = false
var bCanInteract = false
var bPickedUp = false
onready var camera = $Camera2D
onready var BlockTutorial = $BlockingTutorial

func _ready():
	$Vladimir/AnimatedSprite/WeaponHitbox/CollisionShape2D.disabled = true
	yield(get_tree().create_timer(3.0),"timeout")
	if $Vladimir.position.x == 150:
		$MovementTutorial.show()
		yield(get_tree().create_timer(4.0),"timeout")
		$MovementTutorial.queue_free()
# ------------------------------------------------------------------------------
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if bCanInteract:
			$Rake/Label.show()
			$InteractTutorial.queue_free()
			$Vladimir/AnimatedSprite/WeaponHitbox/CollisionShape2D.disabled = false
			# Set new animation set
		if bLetter && $Letter.bCanInteract:
			$Letter/Text.show()
			yield(get_tree().create_timer(7.0),"timeout")
			get_tree().change_scene("res://Level/Prologue/KidnapLevel.tscn")
	if bBOSS:
		$BossHPBar.show()
		$BossHPBar/Label.text = 'Warden: ' + str($Enemy/BOSS_Warden.health) 
		$BossHPBar/Health.rect_size.x = 60 * $Enemy/BOSS_Warden.health
		BOSS_Warden.Move_children()
		if BOSS_Warden.health <= BOSS_Warden.maxHealth / 2:
			$StaticBody2D.show()
			$StaticBody2D/CollisionShape2D.disabled = false
			$Branch/Area2D/CollisionShape2D.disabled = false
		if BOSS_Warden.bIsDead && bBOSS:
			bBOSS = false
			bLetter = true
			add_child(Letter)
			Letter.position = Vector2($Enemy/BOSS_Warden.position.x,$Enemy/BOSS_Warden.position.y+100)
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
	$Enemy.add_child(BOSS_Warden)
	BOSS_Warden.position = Vector2(5,910)
	yield(get_tree().create_timer(0.2),"timeout")
	bBOSS = true
	yield(get_tree().create_timer(1.5),"timeout")
	BlockTutorial.show()
	yield(get_tree().create_timer(4.0),"timeout")
	BlockTutorial.queue_free()
	$Branch/Area2D2/CollisionShape2D.disabled = false
# ------------------------------------------------------------------------------


func _on_ButtonWatch_pressed():
	$UserInterface/PocketWatch.visible = !$UserInterface/PocketWatch.visible
func _on_ButtonSlingshot_pressed():
	$UserInterface/Slingshot.visible = !$UserInterface/Slingshot.visible
	$UserInterface/Rocks.visible = !$UserInterface/Rocks.visible
