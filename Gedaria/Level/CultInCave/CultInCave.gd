extends Node2D
var y = 5650

signal enemy_health_changed

const ROPE_PATH = preload("res://Rope_test/rope_spring.tscn")
const PATROLLER_PATH = preload("res://Enemy/E-Test/Patroller.tscn")
const GUARDIAN_PATH = preload("res://Enemy/E-Test/Guardian.tscn")

var is_done_once = true
var is_yield_paused = false
var is_rope_interactable = false
var is_lever_interactable = false
var is_rope_on_place = false

var arr_enemies = []

onready var leaf_holders = [
	$LeafHolders/LeafHolder49,
	$LeafHolders/LeafHolder50,
	$LeafHolders/LeafHolder51,
]

onready var arr_bats = [
	$Bat,$Bat2,$Bat3,$Bat4,$Bat5,
	$Bat6,$Bat7,$Bat8,$Bat9,$Bat10,
	$Bat11,
]

onready var arr_patrollers = [
	$Patroller,$Patroller2,$Patroller3,
	$Patroller4,$Patroller5,
]
onready var arr_guardians = [
	$Guardian,$Guardian2,$Guardian3,
]


func _ready():
	Global.set_player_position_at_start($Vladimir, $Level_start)
	Global.is_first_entrance(self.filename)
	
	get_tree().set_pause(true)
	SaveLoad.load_map()
	Fullscreen.hide_elements()
	
	$Vladimir.heavy_attack_counter += 4
# ------------------------------------------------------------------------------

func _on_LoadingTimer_timeout(): # Yield() doesn't work in ready() so an autostart timer is needed
	SaveLoad.update_current_data()
	yield(get_tree().create_timer(0.1), "timeout")

	get_tree().set_pause(false)
	Global.is_yield_paused = false

	var leaf_holders = $LeafHolders.get_children() + $PillarLeafolders.get_children()
	for leaf_holder in leaf_holders:
		if leaf_holder.has_leaf:
			leaf_holder.show_leaf()
	
	Global.update_data_from_merchant($Vladimir)
	
	$CanvasLayer/UserInterface.load_ui_icons()
	arr_enemies.insert(0, $Patroller)
	arr_enemies.insert(1, $Guardian)
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _process(delta):
#	$Patroller.move($Patroller.from,$Patroller.to)
#	$Guardian.move()
#	$Guardian.move_in_range($Guardian.from, $Guardian.to)
	
	for i in arr_patrollers:
		i.move(i.from, i.to)
	
	for i in arr_guardians:
		i.move()
		if i.from != 0 or i.to != 0:
			i.move_in_range(i.from, i.to)
	
	for bat in arr_bats:
		bat.move(bat.from, bat.to)
	
	if Input.is_action_just_pressed("interact"):
		if is_rope_interactable:
			$RopeUnderStone.call_deferred("queue_free")
			$rope_spring.call_deferred("queue_free")
			
			var rope = ROPE_PATH.instance()
			$Vladimir.add_child(rope)
			rope.position -= Vector2(750, -20)
			
		elif is_lever_interactable and is_rope_on_place:
			is_rope_on_place = false
			$AnimationPlayer.play("ELEVATOR_UP")
			$RopeArea.call_deferred("queue_free")
			
	if $PillarLeft.position.y == 6890:
		if $PillarLeafolders.get_child_count() == 0:
			$AnimationPlayer.play("PILLAR_MIDDLE_COLLAPSIN")
	
	if $PillarLeft.position.y == 7120:
		if $BreakableFloors/PillarBreakableFloors.get_child_count() == 0:
			$AnimationPlayer.play("PILLARS_COLLAPSING")
	
	if $PileOfLeaves/PileOf4Leaves5.is_complete:
		$Winds/Wind11.disable_wind()
	
	if $Vladimir.position.x >= 8660:
		for leaf_holder in leaf_holders:
			if is_instance_valid(leaf_holder):
				leaf_holder.spawn_leaf()
				SaveLoad.delete_actor(leaf_holder)
# ------------------------------------------------------------------------------

func _on_KillZone_body_entered(body, sec=0.5): # Kills player if he fall into
	if body.get_collision_layer_bit(1):
		yield(get_tree().create_timer(sec), "timeout")
		body.die()
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		$RollingStones.sleeping = false
		$RollingStones.add_central_force(Vector2(15, 1500))
		$RollingStones.show()
# ------------------------------------------------------------------------------

func _on_RopeUnderStone_body_entered(body):
	if body.get_collision_layer_bit(1):
		$RopeUnderStone/TextBackground.show()
		is_rope_interactable = true
# ------------------------------------------------------------------------------

func _on_RopeUnderStone_body_exited(body):
	if body.get_collision_layer_bit(1):
		$RopeUnderStone/TextBackground.hide()
		is_rope_interactable = false
# ------------------------------------------------------------------------------

func _on_RopeUnderStone2_body_entered(body):
	if body.get_collision_layer_bit(1) and body.has_node("rope_spring"):
		$Vladimir/rope_spring.call_deferred("queue_free")
		$rope_spring2.show()
		is_rope_on_place = true
# ------------------------------------------------------------------------------

func _on_AnimationPlayer_animation_finished(anim_name):
	$Vladimir/Camera.current = true
	$Vladimir.can_move = true
# ------------------------------------------------------------------------------

func _on_RopeArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		$RopeArea/TextBackground.show()
		is_lever_interactable = true
# ----------------------------------------------------------------------------

func _on_RopeArea_body_exited(body):
	if body.get_collision_layer_bit(1):
		$RopeArea/TextBackground.hide()
		is_lever_interactable = false
# ------------------------------------------------------------------------------

func _on_TrapDoorMechanismArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		$TrapDoor/TrapDoorMechanismArea/CollisionShape2D.set_deferred("disabled", true)
		$AnimationPlayer.play("OPEN_TRAPDOOR")
# ------------------------------------------------------------------------------

func _on_CollapsingArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		SaveLoad.delete_actor($CollapsingFloors/CollapsingFloor)
# ------------------------------------------------------------------------------

func _on_AmbushArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		$AmbushArea/CollisionShape2D.set_deferred("disabled", true)
		$Guardian2.position = Vector2(21400, 8190)
		$Guardian3.position = Vector2(23100, 8190)
		
		for patroller in arr_patrollers:
			var offset = arr_patrollers.find(patroller)
			if offset > 0:
				patroller.position = Vector2(offset * 350 + 21500, 8190)
# ------------------------------------------------------------------------------
