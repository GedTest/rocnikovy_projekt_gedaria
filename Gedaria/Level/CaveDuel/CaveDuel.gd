extends Node2D

signal crashed_in_pile

const PileOfLeavesPath = preload("res://Level/PileOf4Leaves.tscn")
const MushroomPath = preload("res://Level/Mushroom.tscn")

var is_yield_paused = false

onready var spawn_positions = [$Position1.position,$Position2.position, 
							   $Position3.position, $Position4.position]


func _ready():
	connect("crashed_in_pile", $BOSS_IN_CAVE, "on_crashed_in_pile")
	$Vladimir/Camera.current = false
	Global.set_player_position_at_start($Vladimir, $Level_start)
	
	get_tree().set_pause(true)
	SaveLoad.load_map()
# ------------------------------------------------------------------------------

func _on_LoadingTimer_timeout(): # Yield() doesn't work in ready() so an autostart timer is needed
	SaveLoad.update_current_data()
	yield(get_tree().create_timer(0.1), "timeout")
	
	get_tree().set_pause(false)
	Global.is_yield_paused = false
	Global.is_pausable = true
	$CanvasLayer/UserInterface.load_ui_icons()
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _process(delta):
	$BOSS_IN_CAVE.move()
	
	if $Vladimir.health <= 6 and $Mushrooms.get_child_count() < 4:
		if $MushroomSpawnTimer.time_left <= 0.0:
			$MushroomSpawnTimer.start()
			
	$BossHPBar/Label.text = 'BOSS_IN_CAVE: ' + str($BOSS_IN_CAVE.health) 
	$BossHPBar/Health.rect_size.x = 15 * $BOSS_IN_CAVE.health
# ------------------------------------------------------------------------------


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(2) and $PilesOfLeaves/PileOf4Leaves.is_complete:
		if body.is_in_air:
			emit_signal("crashed_in_pile")
			SaveLoad.delete_actor($PilesOfLeaves/PileOf4Leaves)
# ------------------------------------------------------------------------------

func add_pile_of_leaves():
	if $PilesOfLeaves.get_child_count() == 0:
		var pile_of_leaves = PileOfLeavesPath.instance()
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


func _input(event):
	if Input.get_action_strength("ui_accept"):
		$BOSS_IN_CAVE.lunge()


func _on_MushroomSpawnTimer_timeout():
	var mushroom = MushroomPath.instance()
	var rand_index = randi() % 4
	mushroom.position = spawn_positions[rand_index]
	mushroom.hp = "plus"
	if $Vladimir.health <= 6:
		$Mushrooms.add_child(mushroom)
