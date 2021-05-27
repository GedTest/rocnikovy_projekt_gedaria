extends Node2D


signal enemy_health_changed

const ROLLING_TREE_PATH = preload("res://Level/ForestClearing/RollingTree.tscn")
const ENEMY_PATH = preload("res://Enemy/E-Test/Patroller.tscn")
const LEAF_PATH = preload("res://Level/Leaf.tscn")

var is_done_once = true
var has_spawned_once = false
var is_yield_paused = false
var can_spawn = false

var spawn_timer = null

var count = 0
var sec = 0.1

var arr_enemies = []

onready var missing_leaves = [
	$Leaves/Leaf7,$Leaves/Leaf8,
	$Leaves/Leaf9,$Leaves/Leaf10,
	]

onready var arr_patrollers = [
	$Patroller,$Patroller2,$Patroller3,
	$Patroller4,$Patroller5,$Patroller6,
]
onready var arr_guardians = [
	$Guardian,
]
onready var arr_shooters = [
	$Shooter,
]


func _ready():
#	Global.set_player_position_at_start($Vladimir, $Level_start)
	Global.is_first_entrance(self.filename)
	
	get_tree().set_pause(true)
	SaveLoad.load_map()
	Fullscreen.hide_elements()
	
	$Vladimir.heavy_attack_counter += 4
	$Vladimir.has_learned_attack = true
	$Vladimir.has_learned_heavy_attack = true
	$Vladimir.has_learned_blocking = true
	$Vladimir.has_learned_raking = true
	$Bridge.is_broken = true
# ------------------------------------------------------------------------------

func _on_LoadingTimer_timeout(): # Yield() doesn't work in ready() so an autostart timer is needed
	SaveLoad.update_current_data()
	yield(get_tree().create_timer(0.1), "timeout")
	
	get_tree().set_pause(false)
	Global.is_yield_paused = false
	$CanvasLayer/UserInterface.load_ui_icons()
	
	for leaf_holder in $LeafHolders.get_children():
		if leaf_holder.has_leaf:
			leaf_holder.show_leaf()
			
	arr_enemies = arr_guardians + arr_patrollers + arr_shooters
	spawn_timer = get_tree().create_timer(0.0)
	
	if !$PilesOfLeaves/PileOf4Leaves.is_complete:
		for leaf in missing_leaves:
			if !is_instance_valid(leaf):
				var new_leaf = LEAF_PATH.instance()
				$Leaves.call_deferred("add_child", new_leaf)
				new_leaf.position = Vector2(25000, 8650)
	$CanvasLayer/UserInterface/UniqueLeaf.margin_left = 1676
#	$PilesOfLeaves/PileOf6Leaves2/LeafHolder.has_leaf = 1
#	$PilesOfLeaves/PileOf6Leaves2/LeafHolder2.has_leaf = 1
#	$PilesOfLeaves/PileOf6Leaves2/LeafHolder3.has_leaf = 1
#	$PilesOfLeaves/PileOf6Leaves2/LeafHolder4.has_leaf = 1
#	$PilesOfLeaves/PileOf6Leaves2/LeafHolder5.has_leaf = 1
#	$PilesOfLeaves/PileOf6Leaves2/LeafHolder6.has_leaf = 1
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _process(delta):
	for i in arr_patrollers:
		i.move(i.from, i.to)
	
	for i in arr_guardians:
		i.move()
		if i.from != 0 or i.to != 0:
			i.move_in_range(i.from, i.to)
	
	if !$Shooter.can_shoot_in_sector:
		$Shooter/HitRay.rotation_degrees = 180 if $Shooter/Sprite.flip_h else 0
	
		if $Shooter.has_player:
			$Shooter.can_shoot_in_sector = true
			$Shooter/SpotArea/CollisionPolygon2D.disabled = false
			self.spawn_patrollers(3, Vector2(22300, 8450), 20250, 23450)
	if can_spawn:
		self.spawn_rolling_trees()
	
	if $LeafHolders/LeafHolder17.has_leaf and !has_spawned_once:
		has_spawned_once = true
		self.spawn_patrollers(4, Vector2(5730, 9075), 4000, 6900)
# ------------------------------------------------------------------------------

func _on_KillZone_body_entered(body, sec = 0.5): # Kills player if he fall into
	if body.get_collision_layer_bit(1):
		yield(get_tree().create_timer(sec), "timeout")
		body.die()
# ------------------------------------------------------------------------------

func _on_StalkingArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		$Vladimir/Camera.current = false
		$Vladimir/SpecialCamera.current = true
# ------------------------------------------------------------------------------

func _on_StalkingArea_body_exited(body):
	if body.get_collision_layer_bit(1):
		$Vladimir/Camera.current = true
		$Vladimir/SpecialCamera.current = false
		if body.position.x >= 18700:
			SaveLoad.delete_actor($Vladimir/SpecialCamera)
			SaveLoad.delete_actor($StalkingArea)
# ------------------------------------------------------------------------------

func _on_WindArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		$Winds/Wind6.position.x = 25000
		$Winds/Wind6.impulse.x = -10000
		SaveLoad.delete_actor($Winds/Wind5)
		$PilesOfLeaves/PileOf4Leaves.remove_from_group("DoNotBlow")
		$PilesOfLeaves/PileOf4Leaves.set_collision_layer_bit(3, true)
		yield(get_tree().create_timer(1.5, false), "timeout")
		$PilesOfLeaves/PileOf4Leaves.set_collision_layer_bit(3, false)
		SaveLoad.delete_actor($WindArea)
# ------------------------------------------------------------------------------

func spawn_rolling_trees():
	if spawn_timer.time_left <= 0.0:
		spawn_timer = get_tree().create_timer(sec)
		if !is_yield_paused:
			yield(spawn_timer, "timeout")
			
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
		enemy.is_jumping = true
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
