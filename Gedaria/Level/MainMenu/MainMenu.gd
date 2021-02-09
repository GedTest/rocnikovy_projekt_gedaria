extends Control


#var is_yield_paused = true
onready var arr_texts = {
	"start":$VBox/VBox/StartButton,
	"load":$VBox/VBox/LoadButton,
	"options":$VBox/VBox/OptionButton,
	"achievements":$VBox/VBox/AchievementButton,
	"credits":$VBox/VBox/CreditsButton,
	"quit":$VBox/VBox/QuitButton
}

func _ready():
	get_tree().paused = false
	Languages.translate(arr_texts, Global.prefered_language)
# ------------------------------------------------------------------------------

#func _process(delta):
#	Settings.load_settings()
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


func _on_OptionButton_pressed():
	$Languages.show()
