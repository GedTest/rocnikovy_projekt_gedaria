extends Node2D

onready var Boss_Warden = preload("res://Enemy/BOSS_Warden/BOSS_Warden.tscn")
onready var Letter = preload("res://Level/Prologue/Letter.tscn")


var is_boss_on_map = false
var is_letter_on_map = false
var is_item_interactable = false
var is_item_picked_up = false
var is_rake_picked_up = false
var is_yield_paused = false

var Boss = null


func _ready():
	$Vladimir.has_learned_attack = false
	$Vladimir.has_learned_blocking = false
	$Vladimir.has_learned_heavy_attack = false
	$Vladimir.has_learned_raking = false
	$Vladimir/AnimationTree.active = false
	
	$Vladimir.state_machine = $Vladimir/AnimationTree2.get("parameters/playback")
	$Vladimir/Sprite.hide()
	yield(get_tree().create_timer(3.0), "timeout")
	
	if $Vladimir.position.x == 150:
		$MovementTutorial.text = Global.language["czech"]["movement"]
		$MovementTutorial.show()
		yield(get_tree().create_timer(4.0), "timeout")
		$MovementTutorial.queue_free()
# ------------------------------------------------------------------------------

func _process(delta):
	# restart level
	if $Vladimir.health <= 0 and $timer.time_left == 0.0:
			get_tree().paused = true
			$timer.start()
	
	if is_rake_picked_up:
		is_rake_picked_up = false
		
		if find_node("Rake"):
			$Vladimir/Sprite.show()
			$Vladimir/AnimationTree.active = true
			$Vladimir.state_machine = $Vladimir/AnimationTree.get("parameters/playback")
			$Vladimir.remove_child($Vladimir/AnimationTree2)
			$Vladimir.remove_child($Vladimir/Sprite2)
			$Rake.call_deferred("queue_free")
			$Vladimir.has_learned_attack = true
			$InteractTutorial.queue_free()
			$Tree.show()
			$Tree.play('Grow')
			$Shake.start(15, 1.25, 0.1)
			yield(get_tree().create_timer(1.25), "timeout")
			
			$Tree.queue_free()
			$UI/UserInterface.show()
		
	# INTERACT HANDLER
	if Input.is_action_just_pressed("interact"):
		if is_item_interactable:
			$Rake/Label.show()
			$InteractTutorial.hide()
			# Set new animation set
		if is_letter_on_map and $Letter.is_interactable:
			$Letter/Text.show()
			yield(get_tree().create_timer(7.0), "timeout")
			
			get_tree().change_scene("res://Level/Prologue/KidnapLevel.tscn")
	
	if is_boss_on_map:
		# BOSS HP BAR
		$BossHPBar.show()
		$BossHPBar/Label.text = 'Warden: ' + str($Boss.health) 
		$BossHPBar/Health.rect_size.x = 60 * $Boss.health
		
		$Boss.move()
		
		# BOSSES SECOND PHASE
		if $Boss.health <= $Boss.max_health / 2:
			$StaticBody2D.show()
			$StaticBody2D/CollisionShape2D.disabled = false
			$Branch/Area2D/CollisionShape2D.disabled = false
			if $Vladimir.position.x >= 1300:
				$StaticBody2D/Branch.play('Grow')
			
		# IF BOSS IS NO MORE SHOW A LETTER
		if $Boss.is_dead and is_boss_on_map:
			is_boss_on_map = false
			is_letter_on_map = true
			add_child(Letter.instance())
			$Letter.position = Vector2($Boss.position.x, $Boss.position.y+100)
# ------------------------------------------------------------------------------

func _on_InteractTutorial_body_entered(body):
	if body.get_collision_layer_bit(1):
		is_item_interactable = true
		$InteractTutorial/Label.text = Global.language["czech"]["interaction"]
		$InteractTutorial/Label.show()
# ------------------------------------------------------------------------------

func _on_InteractTutorial_body_exited(body):
	if body.get_collision_layer_bit(1):
		is_item_interactable = false
		$InteractTutorial/Label.hide()
# ------------------------------------------------------------------------------

func _on_CombatTutorial_body_entered(body):
	if body.get_collision_layer_bit(1) and is_item_picked_up:
		$CombatTutorial/Label.text = Global.language["czech"]["attack"]
		$CombatTutorial/Label.show()
# ------------------------------------------------------------------------------

func _on_CombatTutorial_body_exited(body):
	if body.get_collision_layer_bit(1):
		$CombatTutorial/Label.hide()
# ------------------------------------------------------------------------------

func _on_Scarecrow_tree_exiting():
	print("hello ")
	$CombatTutorial.queue_free()
	yield(get_tree().create_timer(0.2), "timeout")
	
	Boss = Boss_Warden.instance()
	add_child(Boss)
	Boss.name = "Boss"
	$Boss.position = Vector2(5, 910)
	yield(get_tree().create_timer(0.2), "timeout")
	
	is_boss_on_map = true
	yield(get_tree().create_timer(1.5), "timeout")
	
	$BlockingTutorial.text = Global.language["czech"]["blocking"]
	$BlockingTutorial.show()
	$Vladimir.has_learned_blocking = true
	yield(get_tree().create_timer(4.0), "timeout")
	
	$BlockingTutorial.queue_free()
	$Branch/Area2D2/CollisionShape2D.disabled = false
# ------------------------------------------------------------------------------

func _on_timer_timeout():
	get_tree().change_scene("res://Level/Prologue/TutorialLevel.tscn")
