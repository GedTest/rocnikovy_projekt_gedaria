extends Control

func _on_StartButton_pressed():
	get_tree().change_scene("res://Level/Chase/ChaseLevel.tscn")
# ------------------------------------------------------------------------------
func _on_LoadButton_pressed():
	var level = Save_Load.get_level()
	if level:
		# Load unfinished level
		get_tree().change_scene(level)
# ------------------------------------------------------------------------------
func _on_QuitButton_pressed():
	get_tree().quit()
# ------------------------------------------------------------------------------
