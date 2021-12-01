extends Node2D


var is_yield_paused = false
var has_kicked_once = true
onready var arr_soldiers = [$Patroller,$Patroller4,$Guardian]

func _ready():
	$BOSS_EARL.state_machine.travel('STANDING')
	$BOSS_EARL.has_jumped = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Vladimir.has_learned_raking = false
	$Vladimir/Camera.position.y = -250
	$Patroller4.state_machine.travel('STANDING')
	$Patroller3.state_machine.travel('STANDING')
	yield(get_tree().create_timer(0.5), "timeout")
	$Patroller4/AnimationTree.active = false
	$Patroller3/AnimationTree.active = false
	Fullscreen.hide_elements()
# ------------------------------------------------------------------------------

func _process(delta):
	$BOSS_EARL.move()
	
	if $BOSS_EARL.position.x > 1840 and has_kicked_once:
		has_kicked_once = false
		$BOSS_EARL.is_moving = false
		$BOSS_EARL.has_jumped = true
		$BOSS_EARL.kick()
# ------------------------------------------------------------------------------

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
#		yield(get_tree().create_timer(1.5), "timeout")
#		get_tree().change_scene("res://Level/InTheWood/In the wood.tscn")
# ------------------------------------------------------------------------------

func play_cutscene():
	var SPAWN_POSITION = Vector2(2800, 985)
	$CutsceneEnemies/Guardian.position = SPAWN_POSITION
	$CutsceneEnemies/Patroller.position = SPAWN_POSITION
	
	$CutsceneEnemies.show()
	$CutsceneEnemies.play(2055, 1890, $Vladimir)
