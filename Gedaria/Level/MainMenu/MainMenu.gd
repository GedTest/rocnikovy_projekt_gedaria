extends Control


#var is_yield_paused = true


func _ready():
	get_tree().paused = false
# ------------------------------------------------------------------------------

func _on_StartButton_pressed():
	get_tree().change_scene("res://Level/Chase/ChaseLevel.tscn")
# ------------------------------------------------------------------------------

func _on_LoadButton_pressed():
	$Slots/LoadButtons.show()
	$Slots/Close.show()
# ------------------------------------------------------------------------------

func _on_QuitButton_pressed():
	get_tree().quit()
# ------------------------------------------------------------------------------
