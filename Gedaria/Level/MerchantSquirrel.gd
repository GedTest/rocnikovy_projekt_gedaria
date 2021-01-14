extends Node2D


var is_yield_paused = false


func _ready():
	get_tree().set_pause(true)
	SaveLoad.load_map()
# ------------------------------------------------------------------------------

func _on_LoadingTimer_timeout():
	SaveLoad.update_current_data()
	yield(get_tree().create_timer(0.1), "timeout")
	
	get_tree().set_pause(false)
	Global.is_yield_paused = false
	$CanvasLayer/UserInterface.load_ui_icons()
# ------------------------------------------------------------------------------

func _process(delta):
	pass
# ------------------------------------------------------------------------------
