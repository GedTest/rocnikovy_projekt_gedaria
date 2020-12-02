extends Node


var gui_children = null


# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		
	if Input.is_action_just_pressed("Pause"):
		gui_children = get_node("/root/Node2D/CanvasLayer").get_children()
		for i in gui_children:
			i.visible = !i.visible
