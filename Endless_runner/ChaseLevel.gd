extends Node2D

var Platform = preload("res://Level/Chase/Platform.tscn")
var NextPlatform
var pos
var count = 0

func _ready():
	# Get position of previous floor
	pos = Vector2(position.x+2690,position.y)
# ------------------------------------------------------------------------------
func AddFloorTile():
	pos += Vector2(750,0)
	NextPlatform = Platform.instance()
	NextPlatform.position.x = pos.x
	call_deferred("add_child",NextPlatform)
	count+=1
	if count >= 15:
		get_tree().change_scene("res://Level/Prologue/TutorialLevel.tscn")
# ------------------------------------------------------------------------------
func _on_Area2D_body_entered(body):
	$StartingPlatform2/Label.show()
	$StartingPlatform3/Label.show()
	yield(get_tree().create_timer(0.2),"timeout")
	$WardenRunner.bSlowMotion = true
	$VladRunner.bSlowMotion = true
	yield(get_tree().create_timer(2.5),"timeout")
	$StartingPlatform2/Label.text = ""
	$StartingPlatform3/Label.hide()
	$WardenRunner.bSlowMotion = false
	$VladRunner.bSlowMotion = false
# ------------------------------------------------------------------------------
