extends Node2D


var Platform = preload("res://Level/Chase/Platform.tscn")

var next_platform
var pos
var count = 0
onready var arr_texts = {
	"jumping":$StartingPlatform2/LabelBackgorund/label,
	"crawling":$StartingPlatform3/LabelBackgorund/label,
}


func _ready():
	# Get position of previous floor
	pos = Vector2(position.x+6720, 540)
	Languages.translate(arr_texts, Global.prefered_language)
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
	$StartingPlatform2/LabelBackgorund.show()
	$StartingPlatform3/LabelBackgorund.show()
	
	yield(get_tree().create_timer(0.4), "timeout")
	$WardenRunner.is_slow_motion = true
	$VladRunner.is_slow_motion = true
	
	yield(get_tree().create_timer(1.8), "timeout")
	$StartingPlatform2/LabelBackgorund.hide()
	$StartingPlatform3/LabelBackgorund.hide()
	$WardenRunner.is_slow_motion = false
	$VladRunner.is_slow_motion = false
# ------------------------------------------------------------------------------

func _on_VisibilityNotifier2D_viewport_entered(viewport):
	$Camera2D.current = true
