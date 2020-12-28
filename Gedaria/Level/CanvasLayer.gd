extends CanvasLayer


func _on_SaveButton_pressed(): # Show save slots and save game
	get_parent().find_node("SaveButtons").show()
	get_parent().find_node("Close").show()
	
	$SaveButton.release_focus()
# ------------------------------------------------------------------------------

func _on_LoadButton_pressed(): # Show save slots and load game
	get_parent().find_node("LoadButtons").show()
	get_parent().find_node("Close").show()
	
	$LoadButton.release_focus()
# ------------------------------------------------------------------------------

func _on_RestartButton_pressed(): # Restart the level from beginning
	get_parent().is_yield_paused = true
	$UserInterface.is_yield_paused = get_parent().is_yield_paused
	get_tree().set_pause(true)
	yield(get_tree().create_timer(5.0), "timeout")
	
	SaveLoad.restart_level()
# ------------------------------------------------------------------------------

func _on_MainMenuButton_pressed(): # Go to Main Menu
	get_parent().is_yield_paused = true
	$UserInterface.is_yield_paused = get_parent().is_yield_paused
	get_tree().set_pause(true)
	yield(get_tree().create_timer(7.0), "timeout")
	
	get_tree().change_scene("res://Level/MainMenu/MainMenu.tscn")
