extends Node


const LEVELS = [
	"res://Level/Chase/ChaseLevel.tscn",
	"res://Level/Prologue/TutorialLevel.tscn",
	"res://Level/Prologue/KidnapLevel.tscn"]


func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	
	if Input.is_action_just_pressed("Pause") and Global.is_pausable:
		self.pause()
# ------------------------------------------------------------------------------

func pause():
	$TextureRect.visible = !$TextureRect.visible
	self.get_tree().paused = !self.get_tree().paused
	
	if !Global.level_root().filename in LEVELS:
		var buttons = get_node("/root/Node2D/CanvasLayer").get_children()
		
		for node in buttons:
			if node is Button:
				node.visible = !node.visible
# ------------------------------------------------------------------------------

func hide_elements():
	$TextureRect.hide()
	$TextureRect/TextEdit.hide()
