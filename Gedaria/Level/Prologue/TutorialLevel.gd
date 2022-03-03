extends Node2D

const BossWardenPath = preload("res://Enemy/BOSS_Warden/BOSS_Warden.tscn")
const LetterPath = preload("res://Level/Prologue/Letter.tscn")
const MushroomPath = preload("res://Level/Mushroom.tscn")

const LETTER_SFX = preload("res://sfx/open_letter.wav")
const BOSS_MUSIC = preload("res://Enemy/boss_fight_theme.wav")
const FOREST_MUSIC = preload("res://gedaria_theme1wav.wav")

var is_boss_on_map = false
var is_letter_on_map = false
var is_item_interactable = false
var is_yield_paused = false
var is_pause_time = true
var is_done_once = false

var boss = null

onready var spawn_positions = [
	$Position1.position, 
	$Position2.position, 
	$Position3.position
]


func _ready():
	AudioManager.play_music(FOREST_MUSIC)
	$Vladimir.has_rake = false
	Fullscreen.hide_elements()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Vladimir.damage = 1
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
	yield(get_tree().create_timer(4.0), "timeout")
	
	if $Vladimir.position.x == 150:
		$TutorialSign3.show()
	
	$BossHPBar/Label.text = Languages.languages[Global.prefered_language]["boss1"]
# ------------------------------------------------------------------------------

func _physics_process(delta):
	if Input.is_action_pressed("block") and find_node("TutorialSign2"):
		if $Vladimir.has_learned_blocking:
			find_node("TutorialSign2").call_deferred("queue_free")
	
	
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		$TutorialSign3.hide()
		 
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
			$TutorialSign.is_interactable = true
			$Cameraa.current = false
			$InteractTutorial.hide()
			$Rake.call_deferred("queue_free")
			$Vladimir/Sprite.show()
			$Vladimir.has_rake = true
			$Vladimir/AnimationTree.active = true
			$Vladimir.state_machine = $Vladimir/AnimationTree.get("parameters/playback")
			$Vladimir/AnimationTree2.queue_free()
			$Vladimir/Sprite2.queue_free()
			$Rake.call_deferred("queue_free")
			$Vladimir.has_learned_attack = true
			$InteractTutorial/CollisionShape2D.disabled = true
			$Tree.show()
			$Tree.play('Grow')
			$AnimationPlayer/AudioStreamPlayer2D.play()
			$Shake.start(15, 1.25, 0.1)
			yield(get_tree().create_timer(1.3), "timeout")
			
			$Tree.queue_free()
			$UI/UserInterface.show()
			
		if is_letter_on_map and $Letter.is_interactable:
			$Branch/leaves.hide()
			$Branch/AnimationPlayer.stop()
			$Letter/Text.show()
			AudioManager.play_sfx(LETTER_SFX, 0, 0, -2)
			yield(get_tree().create_timer(6.5), "timeout")
			
			get_tree().change_scene("res://Level/Prologue/KidnapLevel.tscn")
	
	if is_boss_on_map:
		if is_pause_time:
			is_pause_time = false
			yield(get_tree().create_timer(1.0), "timeout")
			$TutorialSign.call_deferred("queue_free")
			yield(get_tree().create_timer(2.5), "timeout")
			$Vladimir.has_learned_blocking = true
			Global.is_pausable = true
			$C/TutorialSign2.show_text()
		
		# BOSS HP BAR
		$BossHPBar.show()
		$BossHPBar.calc_health($Boss.health, $Boss.max_health)
		
		$Boss.move()
		
		# BOSSES SECOND PHASE
		if $Boss.health <= $Boss.max_health / 2 and not is_done_once:
			is_done_once = true
			$Vladimir.is_moving = false
			$Boss.can_move_during_cutscene = false
			$Vladimir.damage = 2
			$StaticBody2D.show()
			$StaticBody2D/CollisionShape2D.disabled = false
			$Branch/Area2D/CollisionShape2D.disabled = false
			
			$AnimationPlayer.play("CROW_IN_SPOTLIGHT")
			yield(get_tree().create_timer(4.6), "timeout")
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
# ------------------------------------------------------------------------------

func _on_InteractTutorial_body_exited(body):
	if body.get_collision_layer_bit(1):
		is_item_interactable = false
# ------------------------------------------------------------------------------

func _on_Scarecrow_tree_exiting():
	yield(get_tree().create_timer(0.2), "timeout")
	
	boss = BossWardenPath.instance()
	add_child(boss)
	boss.name = "Boss"
	$Boss.position = Vector2(5, 770)
	yield(get_tree().create_timer(0.2), "timeout")
	
	is_boss_on_map = true
	AudioManager.play_music(BOSS_MUSIC)
	yield(get_tree().create_timer(1.5), "timeout")
	
	$Branch/Area2D2/CollisionShape2D.disabled = false
# ------------------------------------------------------------------------------

func _on_timer_timeout():
	get_tree().change_scene("res://Level/Prologue/TutorialLevel.tscn")
# ------------------------------------------------------------------------------

func _on_MushroomSpawnTimer_timeout():
	var mushroom = MushroomPath.instance()
	var rand_index = randi() % 3
	mushroom.position = spawn_positions[rand_index]
	mushroom.hp = "plus"
	if $Vladimir.health <= 4:
		$Mushrooms.add_child(mushroom)
# ------------------------------------------------------------------------------

func _on_AnimationPlayer_animation_finished(anim_name):
	$Vladimir.is_moving = true
	$Boss.can_move_during_cutscene = true
# ------------------------------------------------------------------------------

func _on_UnderLevelKillZone_body_entered(body):
	if body.get_collision_layer_bit(1):
		_on_timer_timeout()
# ------------------------------------------------------------------------------

func _on_ShakeTimer_timeout():
	if boss:
		if boss.health <= boss.max_health/2:
			$AnimationPlayer.play("shake_lil_branch")
			yield(get_tree().create_timer(0.75), "timeout")
			if $Branch.cracks < 1:
				$Branch/AnimationPlayer.play("shake")
			$ShakeTimer.start()
