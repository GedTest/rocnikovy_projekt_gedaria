extends CanvasLayer


onready var arr_texts = {
	"save":$SaveButton,
	"load":$LoadButton,
	"restart":$RestartButton,
	"main_menu":$MainMenuButton,
	"options":$SettingsButton,
	"audio":$AudioLanguage/HBoxContainer/AudioButton,
	"language":$AudioLanguage/HBoxContainer2/LangButton,
	"back":$AudioSettings/Back,
	"close":$AudioLanguage/HBoxContainer3/Close,
	"master_volume":$AudioSettings/HBoxContainer/MasterPlayerLabel,
	"music_volume":$AudioSettings/HBoxContainer2/MusicPlayerLabel
}


func _ready():
	Languages.translate(arr_texts, Global.prefered_language)
	$Languages/Back.text = $AudioSettings/Back.text
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
		button.update()
	get_parent().find_node("Slots").find_node("Close").show()
	print(get_parent().find_node("Close").visible)
	
	$LoadButton.release_focus()
# ------------------------------------------------------------------------------

func _on_MainMenuButton_pressed(): # Go to Main Menu
	get_parent().is_yield_paused = true
	$MainMenuButton.disabled = true
	$UserInterface.is_yield_paused = get_parent().is_yield_paused
	get_tree().set_pause(true)
	yield(get_tree().create_timer(7.0), "timeout")
	$MainMenuButton.disabled = false
	
	get_tree().change_scene("res://Level/MainMenu/MainMenu.tscn")
# ------------------------------------------------------------------------------

func _on_SettingsButton_pressed():
	$AudioLanguage.show()
# ------------------------------------------------------------------------------

func _on_LangButton_pressed():
	$AudioLanguage.hide()
	$Languages.show()
# ------------------------------------------------------------------------------

func _on_lang_btn_pressed():
	$AudioLanguage.show()
# ------------------------------------------------------------------------------

func _on_AudioButton_pressed():
	$AudioSettings.show()
	$AudioLanguage.hide()
# ------------------------------------------------------------------------------

func _on_Slider_value_changed(value):
	var percentage = value if value > 0 else 0
	var master_sound = AudioServer.get_bus_index("Master")
	
	var is_muted = true if percentage == 0 else false
	AudioServer.set_bus_mute(master_sound, is_muted)

	AudioServer.set_bus_volume_db(master_sound, (percentage/2)-30)
	$AudioSettings/HBoxContainer/percentage.text = str(percentage) + "%"
# ------------------------------------------------------------------------------

func _on_Slider2_value_changed(value):
	var percentage = value if value > 0 else 0

	$UserInterface/MusicPlayer.volume_db = (percentage/2)-30
	$AudioSettings/HBoxContainer2/percentage.text = str(percentage) + "%"
# ------------------------------------------------------------------------------

func _on_Language_Back_pressed():
	$Languages.hide()
	$AudioLanguage.show()
# ------------------------------------------------------------------------------

func _on_Audio_Language_Close_pressed():
	$AudioLanguage.hide()
# ------------------------------------------------------------------------------

func _on_Audio_Back_pressed():
	$AudioSettings.hide()
	$AudioLanguage.show()
# ------------------------------------------------------------------------------
