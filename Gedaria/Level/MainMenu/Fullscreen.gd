extends Node


var gui_children = null


# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		
	if Input.is_action_just_pressed("Pause") and Global.is_pausable:
		gui_children = get_node("/root/Node2D/CanvasLayer").get_children()
		for i in gui_children:
			if i is Button:
				i.visible = !i.visible
