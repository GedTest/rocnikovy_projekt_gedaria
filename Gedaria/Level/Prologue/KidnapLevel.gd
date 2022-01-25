extends Node2D


const HORSE_SFX = preload("res://sfx/HorseNeighing.wav")
const HORSE_GALLOP_SFX = preload("res://sfx/HorseGallop.wav")

var is_yield_paused = false
var has_kicked_once = true
var can_enemy_move = false
onready var arr_soldiers = [$Patroller3, $Guardian]

func _ready():
	$BOSS_EARL.state_machine.travel('STANDING')
	$BOSS_EARL.has_jumped = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Vladimir.has_learned_raking = false
	$Vladimir/Camera.position.y = -250
	$Patroller3.state_machine.travel('STANDING')
	yield(get_tree().create_timer(0.5), "timeout")
	$Patroller3/AnimationTree.active = false
	$Patroller/AnimationTree.active = false
	Fullscreen.hide_elements()
	
	for enemy in arr_soldiers:
		enemy.is_moving = false
# ------------------------------------------------------------------------------
func _process(delta):
	$Vladimir/Rake.show()
	$BOSS_EARL.move()
	
	if can_enemy_move:
		$Patroller3.move($Patroller3.from, $Patroller3.to)
		$Guardian.move()
	
	if $BOSS_EARL.position.x > 1810 and has_kicked_once:
		has_kicked_once = false
		$BOSS_EARL.is_moving = false
		$BOSS_EARL.has_jumped = true
		$BOSS_EARL.kick(true)
		
		yield(get_tree().create_timer(2.5), "timeout")
		$BOSS_EARL.from = 0
		$BOSS_EARL.to = 0
		$BOSS_EARL.direction = -1
		$BOSS_EARL.state_machine.travel('RUN')
		$BOSS_EARL.is_moving = true
		$BOSS_EARL.has_jumped = false
		
		yield(get_tree().create_timer(1.3), "timeout")
		AudioManager.play_sfx(HORSE_SFX, 0)
		can_enemy_move = true
		$Patroller3.scale.x = -1
		for enemy in arr_soldiers:
			enemy.find_node("AnimationTree").active = true
			enemy.is_moving = true
			
		yield(get_tree().create_timer(1.0), "timeout")
		$CutsceneEnemies.run_away(0, -1)
		$AnimationPlayer.play("CART_RIDES_AWAY")
		yield(get_tree().create_timer(1.3), "timeout")
		AudioManager.play_sfx(HORSE_GALLOP_SFX, 1)
		
		yield(get_tree().create_timer(3.0), "timeout")
		$Vladimir.is_moving = true
# -----------------------------------------------------------------------------


func _on_HouseArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		$House/Outside.hide()
# ------------------------------------------------------------------------------

func _on_HouseArea_body_exited(body):
	if body.get_collision_layer_bit(1):
		$House/Outside.show()
# ------------------------------------------------------------------------------

func _on_DoorArea2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		$Vladimir.is_moving = false
		$Vladimir.velocity = $Vladimir.GRAVITY
		self.play_cutscene()
		
		yield(get_tree().create_timer(1.0), "timeout")
		for soldier in arr_soldiers:
			soldier.scale.x *= -1
			
		$BOSS_EARL.is_cutscene_finished = true
		$BOSS_EARL.has_jumped = false
		$BOSS_EARL.state_machine.travel("RUN")
# ------------------------------------------------------------------------------

func play_cutscene():
	var SPAWN_POSITION = Vector2(3000, 985)
	$CutsceneEnemies/Guardian.position = SPAWN_POSITION
	$CutsceneEnemies/Patroller.position = SPAWN_POSITION
	
	$CutsceneEnemies.show()
	$CutsceneEnemies.play(2035, 1870, $Vladimir)
# ------------------------------------------------------------------------------

func _on_DissapearArea_body_entered(body):
	if not body.get_collision_layer_bit(1):
		body.position.x -= 1000
# ------------------------------------------------------------------------------

func _on_VisibilityNotifier2D_screen_exited(object=""):
	if can_enemy_move:
		yield(get_tree().create_timer(0.5), "timeout")
		if is_instance_valid(find_node(object)):
			self.find_node(object).queue_free()
