extends Node2D


const LEAF_PATH = preload("res://Level/Leaf.tscn")
const MUSHROOM_PATH = preload("res://Level/Mushroom.tscn")
const PILE_OF_LEAVES_PATH = preload("res://Level/PileOf6Leaves.tscn")

var is_yield_paused = false
var can_spawn_pile_of_leaves = false
var has_kicked_once = true

var arr_enemy = []

var timer = null

onready var spawning_positions = [
	$Node2D/Position1,$Node2D/Position2,$Node2D/Position3,
	$Node2D/Position4,$Node2D/Position5,$Node2D/Position6,
	$Node2D/Position7,
]

onready var mushroom_positions = [
	$ShroomPos/Position1.position,$ShroomPos/Position2.position,
	$ShroomPos/Position3.position,$ShroomPos/Position4.position,
	$ShroomPos/Position5.position,
]


func _ready():
	timer = get_tree().create_timer(0.0, false)
	Global.set_player_position_at_start($Vladimir, $Level_start)

	get_tree().set_pause(true)
	Global.can_be_paused = false
	SaveLoad.load_map()
	
	
	$Tween.interpolate_property($CutsceneEnemies/Father, "modulate", \
								Color(1,1,1,1), Color(1,1,1,0.3), 1.7, \
								Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween2.interpolate_property($CutsceneEnemies/Father, "scale", \
								Vector2(0.75, 0.75), Vector2.ZERO, 2.8, \
								Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.2)
	$Tween3.interpolate_property($CutsceneEnemies/Father, "position", \
								Vector2(1125,1595), Vector2(1045,1530), 3.5, \
								Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.2)
# ------------------------------------------------------------------------------

func _on_LoadingTimer_timeout(): # Yield() doesn't work in ready() so an autostart timer is needed
	SaveLoad.update_current_data()
	yield(get_tree().create_timer(0.1), "timeout")
	
	get_tree().set_pause(false)
	Global.update_data_from_merchant($Vladimir)
	Fullscreen.hide_elements()
	Global.is_yield_paused = false
	Global.is_pausable = true
	$CanvasLayer/UserInterface.load_ui_icons()
	
	$Vladimir.has_learned_leaf_blower = true
	
	$BOSS_EARL.state_machine.travel('STANDING')
	$BOSS_EARL.has_jumped = false
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _process(delta):
	if not $Vladimir.has_rake:
		$Vladimir.is_moving = false
		Input.action_release("crouch")
		Input.action_release("left")
		Input.action_release("right")
		
	if Input.is_action_pressed("shoot"):
		$Vladimir.shoot()
		
	if $BOSS_EARL.position.x > 970 and has_kicked_once:
		has_kicked_once = false
		$BOSS_EARL.is_moving = false
		$BOSS_EARL.has_jumped = true
		$BOSS_EARL.kick()
		yield(get_tree().create_timer(1.0), "timeout")
		$Vladimir.has_rake = false
		$Vladimir/Rake.hide()
		$BOSS_EARL/Rake.show()
		$BOSS_EARL.state_machine.travel('STANDING')
		
		
		yield(get_tree().create_timer(0.55), "timeout")
		$CutsceneEnemies.run_away(2300, 1)
		
	if is_instance_valid(find_node("CutsceneEnemies")):
		if $CutsceneEnemies/Patroller.position.x > 2300:
			yield(get_tree().create_timer(1.5), "timeout")
			$CutsceneEnemies.play(1200, 1050)
			
		if $CutsceneEnemies/Father.position.x == 1125:
			yield(get_tree().create_timer(1.5), "timeout")
			$Tween.start()
			$Tween2.start()
			$Tween3.start()
			
			yield(get_tree().create_timer(1.0), "timeout")
			$Tween.interpolate_property($BOSS_ONIHRO, "scale", \
								Vector2.ZERO, 3*Vector2.ONE, 1.7, \
								Tween.TRANS_CUBIC, Tween.EASE_IN)
			$Tween2.interpolate_property($BOSS_ONIHRO, "position", \
								Vector2(1045,1545), Vector2(1080,1068), 2.5, \
								Tween.TRANS_CUBIC, Tween.EASE_IN)
			$Tween.start()
			$Tween2.start()
			
			yield(get_tree().create_timer(3.0), "timeout")
			$BOSS_ONIHRO.state_machine.travel("LAUGHTER")
			$CutsceneEnemies/Guardian.position.x += 1
			$CutsceneEnemies/Patroller.position.x += 1
			$CutsceneEnemies.run_away(2200, 1)
			
			yield(get_tree().create_timer(3.0), "timeout")
			$Tween3.interpolate_property($BOSS_ONIHRO, "position", \
						Vector2(1080,1068), Vector2(3300,880), 3.0, \
						Tween.TRANS_EXPO, Tween.EASE_IN)
			$Tween3.start()
			if is_instance_valid(find_node("CutsceneEnemies")):
				$CutsceneEnemies.call_deferred("queue_free")
				yield(get_tree().create_timer(4.0), "timeout")
				$BOSS_ONIHRO.state_machine.travel("FLOATING")
				$Vladimir.pebble_counter = 5
		
		
		
	if $Vladimir.heavy_attack_counter < $Vladimir.heavy_attack_increment:
		$Vladimir.heavy_attack_counter += 1
	
	if $BOSS_ONIHRO.has_spawned_quickleaves:
		if $QuickLeaves.is_completed:
			$BOSS_ONIHRO.explosives_y_level = 1025
			$BOSS_ONIHRO/HandLeft.is_destroying_leaf_holders = true
			$BOSS_ONIHRO/HandRight.is_destroying_leaf_holders = true
			$QuickLeaves/KillZone/CollisionShape2D.set_deferred("disabled", true)
			$BOSS_ONIHRO.is_blowing = false
			if $BOSS_ONIHRO.wind:
				$BOSS_ONIHRO.can_be_hitted_again = true
				$BOSS_ONIHRO.wind = null
				$WindBlowerWind.queue_free()
			
			if not $BOSS_ONIHRO.is_hitted_by_wind and timer.time_left <= 0.0:
				timer = get_tree().create_timer(3.0, false)
				yield(timer, "timeout")
				$BOSS_ONIHRO.spawn_explosives_at($BOSS_ONIHRO.position)
		
	for enemy in arr_enemy:
		if enemy.is_dead:
			var leaf = LEAF_PATH.instance()
			leaf.position = enemy.position
			self.call_deferred("add_child", leaf)
			enemy.set_physics_process(false)
			arr_enemy.erase(enemy)
		
		if enemy is Patroller:
			enemy.move(enemy.from, enemy.to)

		else:
			enemy.move()
			enemy.move_in_range(enemy.from, enemy.to)
	
	if arr_enemy.size() == 0 and can_spawn_pile_of_leaves:
		can_spawn_pile_of_leaves = false
		self.add_pile_of_leaves()
		for e in $Enemies.get_children():
			e.call_deferred("queue_free")
	
	$BOSS_EARL.move()
	if $BOSS_EARL.is_dead and $Camera2D.position.x == 1060:
		$LeafProtector/CollisionShape2D.set_deferred("disabled", true)
		$Camera2D.current = false
		$Vladimir/Camera.current = true
		$Vladimir.is_moving = true

	if $Vladimir.health <= 6 and $Mushrooms.get_child_count() < 4:
		if $MushroomSpawnTimer.time_left <= 0.0:
			$MushroomSpawnTimer.start()
	
	if $Vladimir.health <= 0 and $Timer.time_left == 0.0:
		get_tree().paused = true
		$Timer.start()
		
	if $BOSS_ONIHRO.has_spawned_quickleaves:
		if $QuickLeaves.level == 1:
			$AnimationPlayer.play("MOVE_WITH_QUICKLEAVES")
# ------------------------------------------------------------------------------

func _on_MushroomSpawnTimer_timeout():
	var mushroom = MUSHROOM_PATH.instance()
	var rand_index = randi() % 4
	mushroom.position = mushroom_positions[rand_index]
	mushroom.hp = "plus"
	if $Vladimir.health <= 6:
		$Mushrooms.call_deferred("add_child", mushroom)
# ------------------------------------------------------------------------------

func _on_Timer_timeout():
	get_tree().change_scene("res://Level/Fortress/Fortress.tscn")
# ------------------------------------------------------------------------------

func add_pile_of_leaves():
	if $PilesOfLeaves.get_child_count() == 0:
		var pile_of_leaves = PILE_OF_LEAVES_PATH.instance()
		pile_of_leaves.position = Vector2(1300, 1625)
		$PilesOfLeaves.add_child(pile_of_leaves)
# ------------------------------------------------------------------------------

func destroy_all_leafholders():
	$BOSS_ONIHRO.explosives_y_level = 1646
	$BOSS_ONIHRO.has_spawned_quickleaves = false
	$QuickLeaves.queue_free()
	$BOSS_ONIHRO/HandLeft.is_destroying_leaf_holders = false
	$BOSS_ONIHRO/HandRight.is_destroying_leaf_holders = false
	
	for child in $LeafParticles.get_children():
		child.emitting = true
		
	for child in $QuickLeaves.get_children():
		if "Level" in child.name:
			for level_child in child.get_children():
				SaveLoad.delete_actor(level_child)
# ------------------------------------------------------------------------------

func _on_CaughtVladimirArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		$CaughtVladimirArea/CollisionShape2D.shape = null
		$Vladimir.pebble_counter = 0
		self.play_cutscene()
# ------------------------------------------------------------------------------

func play_cutscene():
	var SPAWN_POSITION = Vector2(2200, 1570)
	$CutsceneEnemies/Guardian.position = SPAWN_POSITION
	$CutsceneEnemies/Patroller.position = SPAWN_POSITION
	
	$CutsceneEnemies.play(1200, 1050, $Vladimir)
# ------------------------------------------------------------------------------

func _on_PebbleHitArea_body_entered(body):
	if body.get_collision_layer_bit(7):
		$AnimationPlayer.play("THROW_RAKE")
		$BOSS_EARL/Rake.hide()
		
		yield(get_tree().create_timer(1.5), "timeout")
		$Vladimir.has_rake = true
		$Vladimir.is_moving = true
		$Vladimir.is_aiming = false
		$Vladimir.can_move = true
		
		$BOSS_EARL.is_moving = true
		$BOSS_EARL.has_jumped = false
		$BOSS_EARL.is_cutscene_finished = true
		$BOSS_EARL.can_throw_foot_traps = true
		$BOSS_EARL/CanvasLayer/BossHPBar.show()
		
		$PebbleHitArea/CollisionShape2D.shape = null
		$LeafProtector/CollisionShape2D.set_deferred("disabled", false)
