extends CanvasLayer


onready var arr_texts = {
	"save":$SaveButton,
	"load":$LoadButton,
	"restart":$RestartButton,
	"main_menu":$MainMenuButton,
	"options":$SettingsButton,
	"audio":$Settings/SettingsTree/HBoxContainer/AudioButton,
	"language":$Settings/SettingsTree/HBoxContainer2/LangButton,
	"back":$Settings/AudioSettings/Back,
	"close":$Settings/SettingsTree/HBoxContainer3/Close,
	"master_volume":$Settings/AudioSettings/HBoxContainer/MasterPlayerLabel,
	"music_volume":$Settings/AudioSettings/HBoxContainer2/MusicPlayerLabel,
	"reset_keys":$Settings/KeyBinding/ResetKeys,
	"key_binding":$Settings/SettingsTree/HBoxContainer4/BindingButton
}


func _ready():
	Languages.translate(arr_texts, Global.prefered_language)
# ------------------------------------------------------------------------------

func _process(delta):
	$Settings/Languages/Back.text = $Settings/AudioSettings/Back.text
	$Settings/KeyBinding/Close.text = $Settings/SettingsTree/HBoxContainer3/Close.text
# ------------------------------------------------------------------------------

func _on_SaveButton_pressed(): # Show save slots and save game
	get_parent().find_node("SaveButtons").show()
	get_parent().find_node("Slots").find_node("Close").show()
	
	$SaveButton.release_focus()
# ------------------------------------------------------------------------------

func _on_LoadButton_pressed(): # Show save slots and load game
	var load_buttons = get_parent().find_node("LoadButtons")
	load_buttons.show()
	for button in load_buttons.get_children():
		button.disabled = false
		button.update()
	get_parent().find_node("Slots").find_node("Close").show()
	
	$LoadButton.release_focus()
# ------------------------------------------------------------------------------

func _on_MainMenuButton_pressed(): # Go to Main Menu
	Fullscreen.show_loading_screen()
	get_parent().is_yield_paused = true
	$MainMenuButton.disabled = true
	$UserInterface.is_yield_paused = get_parent().is_yield_paused
	get_tree().set_pause(true)
	yield(get_tree().create_timer(7.0), "timeout")
	$MainMenuButton.disabled = false
	
	get_tree().change_scene("res://Level/MainMenu/MainMenu.tscn")
# ------------------------------------------------------------------------------

func _on_SettingsButton_pressed():
	$Settings.is_visible = true
	$Settings/SettingsTree.show()
	Fullscreen.hide_pause_menu()
# ------------------------------------------------------------------------------
