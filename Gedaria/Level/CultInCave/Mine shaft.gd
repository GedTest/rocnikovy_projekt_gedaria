extends Level


const y = 5650

signal on_vladimir_escaped
signal enemy_health_changed

const ROPE_PATH = preload("res://Rope_test/rope_spring.tscn")
const PATROLLER_PATH = preload("res://Enemy/E-Test/Patroller.tscn")
const GUARDIAN_PATH = preload("res://Enemy/E-Test/Guardian.tscn")
const CAVE_DUEL = "res://Level/CaveDuel/Cave duel.tscn"
const MUSHROOM_PATH = preload("res://Level/Mushroom.tscn")

const BOULDER_ROLLING_SFX = preload("res://sfx/boulder_rolling.wav")
const COLLAPSING_SFX = preload("res://sfx/collapsing.wav")
const SPLASH_SFX = preload("res://sfx/splash.wav")
const BARS_UP_SFX = preload("res://sfx/bars_up.wav")

var is_rope_interactable = false
var is_lever_interactable = false
var is_rope_on_place = false
var has_cage_parent_root = false

onready var rolling_stone_leaf_holders = [
	$LeafHolders/LeafHolder49,
	$LeafHolders/LeafHolder50,
	$LeafHolders/LeafHolder51,
	$LeafHolders/LeafHolder52,
]

onready var arr_bats = [
	$Bat,$Bat2,$Bat3,$Bat4,$Bat5,
	$Bat6,$Bat7,$Bat8,$Bat9,$Bat10,
	$Bat11,
]

onready var spawning_positions = [
	$Node2D/Position1,$Node2D/Position2,$Node2D/Position3,
	$Node2D/Position4,$Node2D/Position5,$Node2D/Position6,
	$Node2D/Position7,
]
onready var mushroom_positions = [
	$Node2D/Position8.position,$Node2D/Position9.position,$Node2D/Position10.position,
	$Node2D/Position11.position,$Node2D/Position12.position,
]


func _ready():
	arr_patrollers = [
		$Patroller,$Patroller2,$Patroller3,
		$Patroller4,$Patroller5,
	]
	
	arr_guardians = [
		$Guardian,$Guardian2,$Guardian3,
	]
	$RollingStones.gravity_scale = 0.0
# ------------------------------------------------------------------------------

func _on_LoadingTimer_timeout(): # Yield() doesn't work in ready() so an autostart timer is needed
	leaf_holders += $PillarLeafolders.get_children()
	._on_LoadingTimer_timeout()
	
	Global.update_data_from_merchant($Vladimir)
	acorn_counter = 50
	unique_leaves_counter = 1
	
	arr_enemies.insert(0, $Patroller)
	arr_enemies.insert(1, $Guardian)
	$RollingStones.sleeping = true
	$BOSS_IN_CAVE.can_emit_signal = false
	
	if Global.is_boss_on_map:
		if Global.is_done_once:
			Global.is_done_once = false
			$Vladimir.position = Vector2(21900, 8195)
			
			
		$AnimationPlayer.play("ELEVATOR_UP_HALF")
		$Vladimir.is_moving = false
		yield(get_tree().create_timer(1.0), "timeout")
		$BOSS_IN_CAVE.is_moving = false
		$BOSS_IN_CAVE.state_machine.travel("STANDING")
		$Vladimir.is_moving = true
		$BOSS_IN_CAVE/CollisionShape2D.set_deferred("disabled" , false)
		$BOSS_IN_CAVE.set_variable_health($Vladimir.damage)
		connect("on_vladimir_escaped", $Vladimir/Cage, "on_vladimir_escaped")
			
		$BOSS_IN_CAVE/CanvasLayer/BossHPBar.show()
		set_vladimir_values_after_duel()
		$BOSS_IN_CAVE.set_values()
	else:
		$BOSS_IN_CAVE/CanvasLayer/BossHPBar.hide()
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _process(delta):
	if Global.is_boss_on_map:
		$BOSS_IN_CAVE.move()
		if $Vladimir.health <= 8 and $MushroomsBoss.get_child_count() < 4:
			if $MushroomSpawnTimer.time_left <= 0.0:
				$MushroomSpawnTimer.start()
				
	for bat in arr_bats:
		if bat:
			bat.move(bat.from, bat.to)
	
	if $RollingStones.gravity_scale != 0 and $Vladimir.position.x < 11600:
		if not AudioManager.is_playing_sfx(BOULDER_ROLLING_SFX):
			AudioManager.play_sfx(BOULDER_ROLLING_SFX, 0, 0, -8)
				
	
	if Input.is_action_just_pressed("interact"):
		if is_rope_interactable:
			$Vladimir.can_move = false
			$AnimationPlayer.play("TO_DO_2")
			$RopeUnderStone.call_deferred("queue_free")
			$rope_spring.call_deferred("queue_free")
			yield(get_tree().create_timer(8.0, false), "timeout")
			$Vladimir.can_move = true
			
			var rope = ROPE_PATH.instance()
			$Vladimir.add_child(rope)
			rope.position -= Vector2(750, -20)
			
		elif is_lever_interactable and is_rope_on_place:
			is_rope_on_place = false
			$AnimationPlayer.play("LEVER_DOWN")
			yield(get_tree().create_timer(0.3, false), "timeout")
			$AnimationPlayer.play("ELEVATOR_UP")
			AudioManager.play_sfx(BARS_UP_SFX)
			$RopeArea.call_deferred("queue_free")
			
	if $PillarLeft/Top.position.y == -915:
		if $PillarLeafolders.get_child_count() == 0:
			AudioManager.play_sfx(COLLAPSING_SFX, 1, -1.0, -10)
			$AnimationPlayer.play("PILLAR_MIDDLE_COLLAPSIN")
	
	if $PillarLeft/Top.position.y == -315:
		if $BreakableFloors/PillarBreakableFloors.get_child_count() == 0:
			$AnimationPlayer.play("PILLARS_COLLAPSING")
	
	if $PilesOfLeaves/PileOf4Leaves5.is_complete:
		$Winds/Wind11.disable_wind()
	
	if $Vladimir.position.x >= 8660 and $Vladimir.position.x <= 9000:
		for leaf_holder in rolling_stone_leaf_holders:
			if is_instance_valid(leaf_holder):
				leaf_holder.spawn_leaf()
				SaveLoad.delete_actor(leaf_holder)
# ------------------------------------------------------------------------------

func _on_MushroomSpawnTimer_timeout():
	var mushroom = MUSHROOM_PATH.instance()
	var rand_index = randi() % 4
	mushroom.position = mushroom_positions[rand_index]
	mushroom.hp = "plus"
	if $Vladimir.health <= 6:
		$MushroomsBoss.call_deferred("add_child", mushroom)
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		AudioManager.play_sfx(BOULDER_ROLLING_SFX, 0, 0, -8)
		$RollingStones.gravity_scale = 10.0
		$RollingStones.linear_velocity = Vector2(500, 0)
		$RollingStones.applied_force = Vector2(500, 0)
		$RollingStones.add_central_force(Vector2(100, 1700))
		$RollingStones.show()
		$Vladimir/Camera.position.y = -20
# ------------------------------------------------------------------------------

func _on_RopeUnderStone_body_entered(body):
	if body.get_collision_layer_bit(1):
		is_rope_interactable = true
# ------------------------------------------------------------------------------

func _on_RopeUnderStone_body_exited(body):
	if body.get_collision_layer_bit(1):
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
		is_lever_interactable = true
# ----------------------------------------------------------------------------

func _on_RopeArea_body_exited(body):
	if body.get_collision_layer_bit(1):
		is_lever_interactable = false
# ------------------------------------------------------------------------------

func _on_TrapDoorMechanismArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		$TrapDoor/TrapDoorMechanismArea/CollisionShape2D.set_deferred("disabled", true)
		$AnimationPlayer.play("OPEN_TRAPDOOR")
# ------------------------------------------------------------------------------

func _on_AmbushArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		$AnimationPlayer.play("FAKE_FAMILY")
		$Vladimir.stop_moving_during_cutsene(3.0)
		yield(get_tree().create_timer(3.0), "timeout")
		
		var ambush_enemies = [
			$Guardian2,$Guardian3,$Patroller2,
			$Patroller3,$Patroller4,$Patroller5,
		]
		$AmbushArea/CollisionShape2D.set_deferred("disabled", true)
		var offset
		for enemy in ambush_enemies:
			offset = ambush_enemies.find(enemy)*500
			enemy.position = Vector2(21400+offset, 8185)
# ------------------------------------------------------------------------------

func _on_CutsceneArea_body_entered(body):
	$Vladimir.stop_moving_during_cutsene(15.0)
	$AnimationPlayer.play("TO_DO")
	$CutsceneArea/CollisionShape2D.set_deferred("disabled", true)
# ------------------------------------------------------------------------------

func _on_FinalLeafHolders_body_entered(body):
	$QuickLeaves2/Area2D/CollisionShape2D.set_deferred("disabled", true)
	$QuickLeaves2/KillZone/CollisionShape2D.set_deferred("disabled", true)
	$FinalLeafHolders/CollisionPolygon2D.set_deferred("disabled", true)
	$BOSS_IN_CAVE.to = 27500
	$BOSS_IN_CAVE.position = Vector2(25588, 5060)
	var array = [
		$QuickLeaves2/Level0/LeafHolder9,
		$QuickLeaves2/Level0/LeafHolder10,
		$QuickLeaves2/Level0/LeafHolder11,
	]
	fill_quick_leaf_holders(array)
	$QuickLeaves2.set_script(null)
	$Checkpoint8.hide()
	$Checkpoint8.position = Vector2(26958, 4904)
	yield(get_tree().create_timer(1.0), "timeout")
	$Checkpoint8/CollisionShape2D.set_deferred("disabled", true)
# ------------------------------------------------------------------------------

func _on_QuickLeaves_body_entered(body):
	var array = [
		$QuickLeaves2/Level11/LeafHolder0,
		$QuickLeaves2/Level10/LeafHolder0,
	]
	fill_quick_leaf_holders(array)
# ------------------------------------------------------------------------------

func fill_quick_leaf_holders(array):
	for leaf_holder in array:
		leaf_holder.has_leaf = 1
		leaf_holder.set_texture()
# ------------------------------------------------------------------------------

func set_vladimir_values_after_duel():
	var vladimir_data = "["+CAVE_DUEL+", Vladimir]"
	var data = SaveLoad.slots["slot_4"][vladimir_data]
	
	if SaveLoad.slots["slot_4"].has(vladimir_data):
		$Vladimir.set_values(data)
# ------------------------------------------------------------------------------

func set_quick_leaves(is_vlad_in_cage=false):
	var old_child = $Cage if has_cage_parent_root else $Vladimir/Cage
	var new_parent = $Vladimir if has_cage_parent_root else self
	
	if is_vlad_in_cage:
		emit_signal("on_vladimir_escaped")
	
	if not has_cage_parent_root:
		old_child.prepare()
	reparent(old_child, new_parent)
# ------------------------------------------------------------------------------

func reparent(child, new_parent):
	child.visible = not child.visible
	var old_parent = child.get_parent()
	old_parent.remove_child(child)
	new_parent.call_deferred("add_child", child)
	has_cage_parent_root = not has_cage_parent_root
	child.position = $Vladimir.position+Vector2(0, -40) if has_cage_parent_root else Vector2(0, 0)
	
	if child.get_parent() is Vladimir:
		connect("on_vladimir_escaped", child, "on_vladimir_escaped")
# ------------------------------------------------------------------------------

func _on_Checkpoint9_body_entered(body):
	$Checkpoint9.position = Vector2(27980, 5174)
# ------------------------------------------------------------------------------

func _on_Area2D2_body_entered(body):
	$Vladimir/Camera.position.y = -200
# ------------------------------------------------------------------------------

func _on_LeafBlowerEnable_body_entered(body):
	if body.get_collision_layer_bit(1):
		$LeafBlowerEnable/LeafBlower.show()
		$LeafBlowerEnable/Label.text = Languages.languages[Global.prefered_language]["mom"]
		$CanvasLayer/UserInterface.update_health(body.max_health-body.health, \
											"plus", body.health, body.max_health)
		body.health = body.max_health
		body.has_learned_leaf_blower = true
# ------------------------------------------------------------------------------

func _on_LeafBlowerEnable_body_exited(body):
	if body.get_collision_layer_bit(1):
		$LeafBlowerEnable/LeafBlower.hide()
		$LeafBlowerEnable/Label.text = ""
# ------------------------------------------------------------------------------

func _on_VisibilityNotifier2D_viewport_entered(viewport):
	if $BOSS_IN_CAVE.is_dead:
		AudioManager.play_sfx(BARS_UP_SFX)
		$AnimationPlayer.play("BARS_UP")
# ------------------------------------------------------------------------------

func _on_RunBossArea_body_entered(body):
	if body.get_collision_layer_bit(1) and Global.is_boss_on_map:
		$BOSS_IN_CAVE.is_moving = true
		$RunBossArea/CollisionShape2D.set_deferred("disabled", true)
		$AnimationPlayer.play("RUN_BOSS")
# ------------------------------------------------------------------------------

func _on_SplashArea_body_entered(body):
	AudioManager.play_sfx(SPLASH_SFX, 0, 0, -6)
