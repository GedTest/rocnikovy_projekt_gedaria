extends Node2D

signal crashed_in_pile

const PILE_OF_LEAVES_PATH = preload("res://Level/PileOf4Leaves.tscn")
const MUSHROOM_PATH = preload("res://Level/Mushroom.tscn")

var is_yield_paused = false

var vlad_damage = 2

var boss = null

onready var spawn_positions = [$Position1.position,$Position2.position, 
							   $Position3.position, $Position4.position]


func _ready():
	connect("crashed_in_pile", $BOSS_IN_CAVE, "on_crashed_in_pile")
	
	$Vladimir/Camera.current = false
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
	$Vladimir.damage = 6
	vlad_damage = $Vladimir.damage
	
	boss = $BOSS_IN_CAVE
	boss.set_variable_health(vlad_damage)
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _process(delta):
	if not find_node("BOSS_IN_CAVE"):
		boss = $MineCart2/BOSS_IN_CAVE
	if not boss.is_in_minecart:
		boss.move()
	
	if $Vladimir.health <= 6 and $Mushrooms.get_child_count() < 4:
		if $MushroomSpawnTimer.time_left <= 0.0:
			$MushroomSpawnTimer.start()
	
	if $Vladimir.health <= 0 and $timer.time_left == 0.0:
		get_tree().paused = true
		$timer.start()
	
	if $Vladimir.position.x <= -13875:
		$Vladimir.damage = vlad_damage
		$Vladimir.pebble_counter = 0
# ------------------------------------------------------------------------------


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(2) and $PilesOfLeaves/PileOf4Leaves.is_complete:
		if body.is_in_air:
			emit_signal("crashed_in_pile")
			SaveLoad.delete_actor($PilesOfLeaves/PileOf4Leaves)
# ------------------------------------------------------------------------------

func add_pile_of_leaves():
	if $PilesOfLeaves.get_child_count() == 0:
		var pile_of_leaves = PILE_OF_LEAVES_PATH.instance()
		$PilesOfLeaves.add_child(pile_of_leaves)
		
		pile_of_leaves.position = Vector2(650, 1540)
		
		var area = Area2D.new()
		area.name = "2DArea"
		area.set_collision_mask_bit(2,true)
		
		var collision = CollisionShape2D.new()
		collision.shape = RectangleShape2D.new()
		collision.shape.extents = Vector2(160, 95)
		collision.position.x = 10
		
		area.add_child(collision)
		area.connect("body_entered",self,"_on_Area2D_body_entered")
		
		pile_of_leaves.add_child(area)
# ------------------------------------------------------------------------------

func _on_MushroomSpawnTimer_timeout():
	var mushroom = MUSHROOM_PATH.instance()
	var rand_index = randi() % 4
	mushroom.position = spawn_positions[rand_index]
	mushroom.hp = "plus"
	if $Vladimir.health <= 6:
		$Mushrooms.call_deferred("add_child", mushroom)
# ------------------------------------------------------------------------------

func _on_EndArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		Global.is_done_once = true
		Global.is_boss_on_map = true
		Fullscreen.show_loading_screen()
		SaveLoad.save_to_slot("slot_4")
		yield(get_tree().create_timer(0.5), "timeout")
		get_tree().change_scene("res://Level/CultInCave/Mine shaft.tscn")
# ------------------------------------------------------------------------------

func collapse_floor():
	for x in range(-7, 19):
		for y in range(19, 22):
			$TileMap.set_cell(x, y, -1)
	$Camera2D.current = false
	$Vladimir/Camera.current = true
	
	$CanvasLayer/UserInterface.hide()
	$Vladimir.has_slingshot = true
	$Vladimir.pebble_counter = 1
	vlad_damage = $Vladimir.damage
	$Vladimir.damage = 1
	$BOSS_IN_CAVE.is_blocking = false

# ------------------------------------------------------------------------------

func _on_BoosterArea_body_entered(body):
	if body.get_collision_layer_bit(2):
		if is_connected("health_changed", self, "add_pile_of_leaves"):
			body.disconnect("health_changed", self, "add_pile_of_leaves")
		body.is_in_minecart = true
		body.velocity.y = -200
		body.can_emit_signal = false
		
	if body.get_collision_layer_bit(1):
		body.is_moving = false
		yield(get_tree().create_timer(1.0), "timeout")
		body.is_moving = true
		body.velocity.y = -100
# ------------------------------------------------------------------------------

func _on_Timer_timeout():
	get_tree().change_scene("res://Level/CaveDuel/Cave duel.tscn")
# ------------------------------------------------------------------------------

func _on_ReduceDamageArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.damage = 1
