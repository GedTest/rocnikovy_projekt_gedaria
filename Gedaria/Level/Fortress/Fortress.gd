extends Node2D


const LEAF_PATH = preload("res://Level/Leaf.tscn")
const MUSHROOM_PATH = preload("res://Level/Mushroom.tscn")
const PILE_OF_LEAVES_PATH = preload("res://Level/PileOf6Leaves.tscn")

var is_yield_paused = false
var can_spawn_pile_of_leaves = false

var arr_enemy = []

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
#	Global.set_player_position_at_start($Vladimir, $Level_start)

	get_tree().set_pause(true)
	SaveLoad.load_map()
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
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _process(delta):
	if $QuickLeaves.is_completed:
		$BOSS_ONIHRO/HandLeft.is_destroying_leaf_holders = true
		$BOSS_ONIHRO/HandRight.is_destroying_leaf_holders = true
		$AnimationPlayer.play_backwards("MOVE_WITH_QUICKLEAVES")
		
	for enemy in arr_enemy:
		if enemy.is_dead:
			var leaf = LEAF_PATH.instance()
			leaf.position = enemy.position
			self.call_deferred("add_child", leaf)
			arr_enemy.erase(enemy)
		
		if enemy is Patroller:
			enemy.move(enemy.from, enemy.to)

		else:
			enemy.move()
			enemy.move_in_range(enemy.from, enemy.to)
	
	if arr_enemy.size() == 0 and can_spawn_pile_of_leaves:
		can_spawn_pile_of_leaves = false
		self.add_pile_of_leaves()
	
	$BOSS_EARL.move()

	if $Vladimir.health <= 6 and $Mushrooms.get_child_count() < 4:
		if $MushroomSpawnTimer.time_left <= 0.0:
			$MushroomSpawnTimer.start()
	
	if $Vladimir.health <= 0 and $Timer.time_left == 0.0:
		get_tree().paused = true
		$Timer.start()
		
	if not $AnimationPlayer.is_playing() and $QuickLeaves.level == 1:
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
		pile_of_leaves.position = Vector2(650, 1625)
		$PilesOfLeaves.add_child(pile_of_leaves)
# ------------------------------------------------------------------------------

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "MOVE_WITH_QUICKLEAVES":
		$QuickLeaves/KillZone/CollisionShape2D.set_deferred("disabled", true)
