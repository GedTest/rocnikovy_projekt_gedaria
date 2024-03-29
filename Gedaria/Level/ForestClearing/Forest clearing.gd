extends Level


signal enemy_health_changed

const ROLLING_TREE_PATH = preload("res://Level/ForestClearing/RollingTree.tscn")
const ENEMY_PATH = preload("res://Enemy/E-Test/Patroller.tscn")
const LEAF_PATH = preload("res://Level/Leaf.tscn")

const CHOP_SFX = preload("res://sfx/chop_wood2.wav")

var has_spawned_once = false
var can_spawn = false

var spawn_timer = null

var count = 0
var sec = 0.1

onready var missing_leaves = [
	$Leaves/Leaf7,$Leaves/Leaf8,
	$Leaves/Leaf9,$Leaves/Leaf10,
	]


func _ready():
	arr_patrollers = [
		$Patroller,$Patroller2,$Patroller3,
		$Patroller4,$Patroller5,$Patroller6,
	]
	arr_guardians = [
		$Guardian,$Guardian2,$Guardian3
	]
	arr_shooters = [
		$Shooter,
	]
	$Bridge.is_broken = true
# ------------------------------------------------------------------------------

func _on_LoadingTimer_timeout(): # Yield() doesn't work in ready() so an autostart timer is needed
	._on_LoadingTimer_timeout()
	Global.update_data_from_merchant($Vladimir)
	acorn_counter = 50
	unique_leaves_counter = 1
	
	spawn_timer = get_tree().create_timer(0.0)
	
	if not $PilesOfLeaves/PileOf4Leaves.is_complete:
		for leaf in missing_leaves:
			if not is_instance_valid(leaf):
				var new_leaf = LEAF_PATH.instance()
				$Leaves.call_deferred("add_child", new_leaf)
				new_leaf.position = Vector2(25000, 8650)
				
	if $Vladimir.has_slingshot:
		if self.find_node("SlingshotItem"):
			SaveLoad.delete_actor($SlingshotItem)
		$TutorialSign.queue_free()
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _process(delta):
	._process(delta)
	
	if find_node("BOSS_EARL"):
		$BOSS_EARL.move()
		
	if not $Shooter.can_shoot_in_sector:
		$Shooter/HitRay.rotation_degrees = 180 #if $Shooter/Sprite.flip_h else 0
	
		if $Shooter.has_player:
			$Shooter.can_shoot_in_sector = true
			$Shooter/SpotArea/CollisionPolygon2D.disabled = false
			self.spawn_patrollers(3, Vector2(22300, 8450), 20250, 23450)
	if can_spawn:
		self.spawn_rolling_trees()
	
	if $LeafHolders/LeafHolder17.has_leaf and not has_spawned_once:
		has_spawned_once = true
		self.spawn_patrollers(4, Vector2(6300, 8950), 4000, 6900)
# ------------------------------------------------------------------------------

func _on_StalkingArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		$Vladimir/Camera.current = false
		$Vladimir.has_learned_leaf_blower = false
		$Vladimir/SpecialCamera.current = true
		$BOSS_EARL.has_jumped = false
		$BOSS_EARL.is_cutscene_finished = true
# ------------------------------------------------------------------------------

func _on_StalkingArea_body_exited(body):
	if body.get_collision_layer_bit(1):
		$Vladimir/Camera.current = true
		$Vladimir/SpecialCamera.current = false
		$Vladimir.has_learned_leaf_blower = true
		if body.position.x >= 18700:
			SaveLoad.delete_actor($Vladimir/SpecialCamera)
			SaveLoad.delete_actor($StalkingArea)
# ------------------------------------------------------------------------------

func _on_WindArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		$WindArea.position.y += 8000
		$Winds/Wind6.position.x = 25000
		$Winds/Wind6.impulse.x = -10000
		$KillZones/KillZone2.queue_free()
		SaveLoad.delete_actor($Winds/Wind5)
		$PilesOfLeaves/PileOf4Leaves.remove_from_group("DoNotBlow")
		$PilesOfLeaves/PileOf4Leaves.set_collision_layer_bit(3, true)
		yield(get_tree().create_timer(1.5, false), "timeout")
		$PilesOfLeaves/PileOf4Leaves.set_collision_layer_bit(3, false)
		$Tutorial2.position.y = 9120
		SaveLoad.delete_actor($WindArea)
# ------------------------------------------------------------------------------

func spawn_rolling_trees():
	if spawn_timer.time_left <= 0.0:
		spawn_timer = get_tree().create_timer(sec)
		if not is_yield_paused:
			yield(spawn_timer, "timeout")
			
			AudioManager.play_sfx(CHOP_SFX)
			count += 1
			sec = 1.2 if count % 4 == 0 else 3.3
			
			var rolling_tree = ROLLING_TREE_PATH.instance()
			$RollingTrees.add_child(rolling_tree)
			rolling_tree.position = $Spawner.position
			rolling_tree.name = "RollingTree_" + str(count)
			rolling_tree.apply_central_impulse(Vector2(-500, -100))
			
# ------------------------------------------------------------------------------

func spawn_patrollers(number_of_enemies, pos, from, to):
	for number in range(number_of_enemies):
		var enemy = ENEMY_PATH.instance()
		enemy.health = 10
		enemy.damage = 4
		enemy.speed = 250 + number * 15
		enemy.from = from
		enemy.to = to
		enemy.position = Vector2(pos.x - number*30, pos.y)
		enemy.set_deferred("is_jumping", true)
		enemy.FoV = 350
		arr_enemies.append(enemy)
		arr_patrollers.append(enemy)
		self.add_child(enemy)
# ------------------------------------------------------------------------------

func _on_VisibilityNotifier2D_viewport_entered(viewport):
	can_spawn = true

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", false)
		$Area2D/CollisionShape2D.set_deferred("disabled", true)

func _on_Gateway7_body_entered(body):
	if "RollingTree" in body.name:
		$Gateways/Gateway7.is_falling_down = true
		yield(get_tree().create_timer(2.0), "timeout")
		body.queue_free()

func _on_BridgeArea2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		$WindyBridge/CollisionShape2D.set_deferred("disabled", true)
		$Winds/WindBlowerWind.show()
		SaveLoad.delete_actor($LeafHolders.find_node("LeafHolder11"))
		SaveLoad.delete_actor($LeafHolders.find_node("LeafHolder12"))
		SaveLoad.delete_actor($LeafHolders.find_node("LeafHolder13"))
		SaveLoad.delete_actor($LeafHolders.find_node("LeafHolder14"))
# ------------------------------------------------------------------------------

func _on_UnderLevelKillZone_body_entered(body):
	if body.get_collision_layer_bit(0) and "Tree" in body.name:
		SaveLoad.delete_actor(body)
	if body.get_collision_layer_bit(2):
		SaveLoad.delete_actor(body)
