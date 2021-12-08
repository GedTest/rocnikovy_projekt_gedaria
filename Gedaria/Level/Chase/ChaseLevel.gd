extends Node2D


const PLATFORM_PATH = preload("res://Level/Chase/Platform.tscn")
const HAY_SFX = preload("res://sfx/hay.wav")

var next_platform
var pos


func _ready():
	Fullscreen.hide_elements()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	# Get position of previous floor
	pos = Vector2(position.x+6720, 540)
# ------------------------------------------------------------------------------

func add_floor_tile():
	pos += Vector2(1920, 0)
	next_platform = PLATFORM_PATH.instance()
	next_platform.position = pos
	call_deferred("add_child", next_platform)
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	yield(get_tree().create_timer(0.4), "timeout")
	$WardenRunner.is_slow_motion = true
	$VladRunner.is_slow_motion = true
	
	yield(get_tree().create_timer(1.8), "timeout")
	$WardenRunner.is_slow_motion = false
	$VladRunner.is_slow_motion = false
# ------------------------------------------------------------------------------

func _on_VisibilityNotifier2D_viewport_entered(viewport):
	$Camera2D.current = true


func _on_END_body_entered(body):
	get_tree().change_scene("res://Level/Prologue/TutorialLevel.tscn")


func _on_END2_body_entered(body):
	AudioManager.play_sfx(HAY_SFX, 1, 0, -12)
