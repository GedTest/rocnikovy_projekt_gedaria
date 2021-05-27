extends Node2D

const BossWardenPath = preload("res://Enemy/BOSS_Warden/BOSS_Warden.tscn")
const LetterPath = preload("res://Level/Prologue/Letter.tscn")
const MushroomPath = preload("res://Level/Mushroom.tscn")

var is_boss_on_map = false
var is_letter_on_map = false
var is_item_interactable = false
var is_item_picked_up = false
var is_yield_paused = false
var is_pause_time = true

var boss = null

onready var arr_texts = {
	"movement":$MovementTutorial/Label,
	"interaction":$InteractTutorial/Text/TextSprite/RichTextLabel,
	"attack":$CombatTutorial/TextBg/Label,
	"blocking":$BlockingTutorial/Label,
}
onready var spawn_positions = [$Position1.position, 
							   $Position2.position, 
							   $Position3.position]


func _ready():
	Fullscreen.find_node("TextEdit").hide()
	$Vladimir.damage = 1
	Languages.translate(arr_texts, Global.prefered_language)
	get_tree().paused = false
	Global.is_pausable = false
	$Vladimir.has_learned_attack = false
	$Vladimir.has_learned_blocking = false
	$Vladimir.has_learned_heavy_attack = false
	$Vladimir.has_learned_raking = false
	$Vladimir/AnimationTree.active = false
	$Vladimir/Camera.current = false
	
	$Vladimir.state_machine = $Vladimir/AnimationTree2.get("parameters/playback")
	$Vladimir/Sprite.hide()
	yield(get_tree().create_timer(3.0), "timeout")
	
	if $Vladimir.position.x == 150:
		$TutorialAnimation.show()
		$AnimationPlayer.play("TUTORIAL_MOVEMENT")
		$MovementTutorial.show()
		yield(get_tree().create_timer(3.0), "timeout")
		$MovementTutorial.queue_free()
		$TutorialAnimation.hide()
# ------------------------------------------------------------------------------

func _process(delta):
	# restart level
	if $Vladimir.health <= 0 and $timer.time_left == 0.0:
			get_tree().paused = true
			$timer.start()
	
	if $Vladimir.health <= 4 and $Mushrooms.get_child_count() < 3:
		if $MushroomSpawnTimer.time_left <= 0.0:
			$MushroomSpawnTimer.start()
		
	# INTERACT HANDLER
	if Input.is_action_just_pressed("interact"):
		if is_item_interactable:
			$Cameraa.current = false
			$InteractTutorial.hide()
			$Rake.call_deferred("queue_free")
			$Vladimir/Sprite.show()
			$Vladimir/AnimationTree.active = true
			$Vladimir.state_machine = $Vladimir/AnimationTree.get("parameters/playback")
			$Vladimir/AnimationTree2.queue_free()
			$Vladimir/Sprite2.queue_free()
			$Rake.call_deferred("queue_free")
			$Vladimir.has_learned_attack = true
			$InteractTutorial/CollisionShape2D.disabled = true
			$Tree.show()
			$Tree.play('Grow')
			$Shake.start(15, 1.25, 0.1)
			yield(get_tree().create_timer(1.25), "timeout")
			
			$Tree.queue_free()
			$UI/UserInterface.show()
			
		if is_letter_on_map and $Letter.is_interactable:
			$Branch/leaves.hide()
			$Branch/AnimationPlayer.stop()
			$Letter/Text.show()
			yield(get_tree().create_timer(7.0), "timeout")
			
			get_tree().change_scene("res://Level/Prologue/KidnapLevel.tscn")
	
	if is_boss_on_map:
		if is_pause_time:
			if $Boss.state_machine.get_current_node() == "ATTACK" and $Boss.has_player:
				is_pause_time = false
				yield(get_tree().create_timer(0.6), "timeout")
				Fullscreen.pause()
				yield(get_tree().create_timer(3.0), "timeout")
				Global.is_pausable = true
				$Vladimir.has_learned_blocking = true
				$BlockingTutorial.show()
		
		# BOSS HP BAR
		$BossHPBar.show()
		$BossHPBar/Label.text = 'Warden: ' + str($Boss.health) 
		$BossHPBar/Health.rect_size.x = 60 * $Boss.health
		
		$Boss.move()
		
		# BOSSES SECOND PHASE
		if $Boss.health <= $Boss.max_health / 2:
			$Vladimir.damage = 2
			$StaticBody2D.show()
			$StaticBody2D/CollisionShape2D.disabled = false
			$Branch/Area2D/CollisionShape2D.disabled = false
			if $Vladimir.position.x >= 1300:
				$StaticBody2D/Branch.play('Grow')
			
		# IF BOSS IS NO MORE SHOW A LETTER
		if $Boss.is_dead and is_boss_on_map:
			$Boss.z_index = 0
			is_boss_on_map = false
			is_letter_on_map = true
			self.add_child(LetterPath.instance())
			$Letter.position = Vector2($Boss.position.x, $Boss.position.y+100)
# ------------------------------------------------------------------------------

func _on_InteractTutorial_body_entered(body):
	if body.get_collision_layer_bit(1):
		is_item_interactable = true
		$InteractTutorial/Text/TextSprite/RichTextLabel.show()
# ------------------------------------------------------------------------------

func _on_InteractTutorial_body_exited(body):
	if body.get_collision_layer_bit(1):
		is_item_interactable = false
		$InteractTutorial/Text/TextSprite/RichTextLabel.hide()
# ------------------------------------------------------------------------------

func _on_CombatTutorial_body_entered(body):
	if body.get_collision_layer_bit(1) and is_item_picked_up:
		$CombatTutorial.show()
# ------------------------------------------------------------------------------

func _on_CombatTutorial_body_exited(body):
	if body.get_collision_layer_bit(1):
		$CombatTutorial.hide()
# ------------------------------------------------------------------------------

func _on_Scarecrow_tree_exiting():
	$CombatTutorial.queue_free()
	yield(get_tree().create_timer(0.2), "timeout")
	
	boss = BossWardenPath.instance()
	add_child(boss)
	boss.name = "Boss"
	$Boss.position = Vector2(5, 910)
	yield(get_tree().create_timer(0.2), "timeout")
	
	is_boss_on_map = true
	yield(get_tree().create_timer(1.5), "timeout")
	
	$Branch/Area2D2/CollisionShape2D.disabled = false
# ------------------------------------------------------------------------------

func _on_timer_timeout():
	get_tree().change_scene("res://Level/Prologue/TutorialLevel.tscn")


func _on_MushroomSpawnTimer_timeout():
	var mushroom = MushroomPath.instance()
	var rand_index = randi() % 3
	mushroom.position = spawn_positions[rand_index]
	mushroom.hp = "plus"
	if $Vladimir.health <= 4:
		$Mushrooms.add_child(mushroom)
