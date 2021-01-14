extends Node


# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		
	if Input.is_action_just_pressed("Pause") and Global.is_pausable:
		var buttons = get_node("/root/Node2D/CanvasLayer").get_children()
		
		for node in buttons:
			if node is Button:
				node.visible = !node.visible
