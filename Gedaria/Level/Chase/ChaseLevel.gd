extends Node2D


var Platform = preload("res://Level/Chase/Platform.tscn")

var next_platform
var pos
var count = 0


func _ready():
	# Get position of previous floor
	pos = Vector2(position.x+6720, 540)
# ------------------------------------------------------------------------------

func add_floor_tile():
	pos += Vector2(1920, 0)
	next_platform = Platform.instance()
	next_platform.position = pos
	call_deferred("add_child", next_platform)
	count += 1
	if count >= 10:
		get_tree().change_scene("res://Level/Prologue/TutorialLevel.tscn")
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	$StartingPlatform2/Label.text = Global.language["czech"]["jumping"]
	$StartingPlatform2/Label.show()
	$StartingPlatform3/Label.text = Global.language["czech"]["crawling"]
	$StartingPlatform3/Label.show()
	
	yield(get_tree().create_timer(0.4), "timeout")
	$WardenRunner.is_slow_motion = true
	$VladRunner.is_slow_motion = true
	
	yield(get_tree().create_timer(1.8), "timeout")
	$StartingPlatform2/Label.text = ""
	$StartingPlatform3/Label.hide()
	$WardenRunner.is_slow_motion = false
	$VladRunner.is_slow_motion = false
# ------------------------------------------------------------------------------

func _on_VisibilityNotifier2D_viewport_entered(viewport):
	$Camera2D.current = true
