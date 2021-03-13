extends Node2D
var y = 5650

signal enemy_health_changed

const RopePath = preload("res://Rope_test/rope_spring.tscn")

var is_done_once = true
var is_yield_paused = false
var is_rope_interactable = false
var is_lever_interactable = false
var is_rope_on_place = false

var non_pillar_leaf_holders = 30
var arr_enemies = []

onready var arr_bats = [
	$Bat,$Bat2,$Bat3,$Bat4,$Bat5,
	$Bat6,$Bat7,$Bat8,$Bat9,$Bat10,
	$Bat11,
]


func _ready():
	#Global.set_player_position_at_start($Vladimir, $Level_start)
	Global.is_first_entrance(self.filename)
	
	get_tree().set_pause(true)
	SaveLoad.load_map()
	
	$Vladimir.heavy_attack_counter = 4
	$Vladimir.has_slingshot = true
# ------------------------------------------------------------------------------

func _on_LoadingTimer_timeout(): # Yield() doesn't work in ready() so an autostart timer is needed
	SaveLoad.update_current_data()
	yield(get_tree().create_timer(0.1), "timeout")

	get_tree().set_pause(false)
	Global.is_yield_paused = false
	Global.is_pausable = true

	for leaf_holder in $LeafHolders.get_children():
		if leaf_holder.has_leaf:
			leaf_holder.show_leaf()
	
	Global.update_data_from_merchant($Vladimir)
	
	$CanvasLayer/UserInterface.load_ui_icons()
	arr_enemies.insert(0, $Patroller)
	arr_enemies.insert(1, $Guardian)
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _process(delta):
	$Patroller.move($Patroller.from,$Patroller.to)
	$Guardian.move()
	$Guardian.move_in_range($Guardian.from, $Guardian.to)
	
	for bat in arr_bats:
		bat.move(bat.from, bat.to)
	
	if Input.is_action_just_pressed("interact"):
		if is_rope_interactable:
			$RopeUnderStone.call_deferred("queue_free")
			$rope_spring.call_deferred("queue_free")
			
			var rope = RopePath.instance()
			$Vladimir.add_child(rope)
			rope.position -= Vector2(750, -20)
			
		elif is_lever_interactable and is_rope_on_place:
			is_rope_on_place = false
			$AnimationPlayer.play("ELEVATOR_UP")
			$RopeArea.call_deferred("queue_free")
			
	if $PillarLeft.position.y == 6890:
		if $LeafHolders.get_child_count() - non_pillar_leaf_holders == 0:
			$AnimationPlayer.play("PILLAR_MIDDLE_COLLAPSIN")
	
	if $PillarLeft.position.y == 7120:
		if $BreakableFloors/PillarBreakableFloors.get_child_count() == 0:
			$AnimationPlayer.play("PILLARS_COLLAPSING")
			SaveLoad.delete_actor($KillZones/KillZone)
# ------------------------------------------------------------------------------

func _on_KillZone_body_entered(body): # Kills player if he fall into
	if body.get_collision_layer_bit(1):
		yield(get_tree().create_timer(0.5), "timeout")
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
		$TrapDoor/TrapDoorMechanismArea/CollisionShape2D.disabled = true
		$AnimationPlayer.play("OPEN_TRAPDOOR")
# ------------------------------------------------------------------------------

func _on_CollapsingArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		SaveLoad.delete_actor($CollapsingFloors/CollapsingFloor)
# ------------------------------------------------------------------------------
