extends CanvasLayer


const MENU_BTN_SFX = preload("res://sfx/klik_do_menu_i_z_menu.wav")

onready var arr_texts = {
	"save":$SaveButton,
	"load":$LoadButton,
	"restart":$RestartButton,
	"main_menu":$MainMenuButton,
	"options":$SettingsButton,
	"audio":$Settings/SettingsTree/AudioButton,
	"language":$Settings/SettingsTree/LangButton,
	"back":$Settings/AudioSettings/Back,
	"close":$Settings/SettingsTree/Close,
	"master_volume":$Settings/AudioSettings/Master/MasterPlayerLabel,
	"music_volume":$Settings/AudioSettings/Music/MusicPlayerLabel,
	"sfx_volume":$Settings/AudioSettings/SFX/SFXPlayerLabel,
	"key_binding":$Settings/SettingsTree/BindingButton
}


func _ready():
	Languages.translate(arr_texts, Global.prefered_language)
# ------------------------------------------------------------------------------

func _process(delta):
	$Settings/Languages/Back.text = $Settings/AudioSettings/Back.text
	$Settings/VideoSettings/Back.text = $Settings/AudioSettings/Back.text
# ------------------------------------------------------------------------------

func _on_SaveButton_pressed(): # Show save slots and save game
	AudioManager.play_sfx(MENU_BTN_SFX)
	var save_buttons = get_parent().find_node("SaveButtons")
	
	save_buttons.show()
	get_parent().find_node("Slots").find_node("SaveLoadBackground").show()
	
	for button in save_buttons.get_children():
		button.disabled = false
		button.type = "SAVE"
		button.update()
	get_parent().find_node("Slots").find_node("Close").show()
	
	$SaveButton.release_focus()
# ------------------------------------------------------------------------------

func _on_LoadButton_pressed(): # Show save slots and load game
	AudioManager.play_sfx(MENU_BTN_SFX)
	var load_buttons = get_parent().find_node("SaveButtons")
	load_buttons.show()
	get_parent().find_node("Slots").find_node("SaveLoadBackground").show()
	
	for button in load_buttons.get_children():
		button.type = "LOAD"
		button.disabled = false
		button.update()
	get_parent().find_node("Slots").find_node("Close").show()
	
	$SaveButton.release_focus()
# ------------------------------------------------------------------------------

func _on_MainMenuButton_pressed(): # Go to Main Menu
	AudioManager.play_sfx(MENU_BTN_SFX)
	Fullscreen.show_loading_screen()
	get_parent().is_yield_paused = true
	$MainMenuButton.disabled = true
	get_tree().set_pause(true)
	yield(get_tree().create_timer(7.0), "timeout")
	$MainMenuButton.disabled = false
	
	get_tree().change_scene("res://Level/MainMenu/MainMenu.tscn")
# ------------------------------------------------------------------------------

func _on_SettingsButton_pressed():
	AudioManager.play_sfx(MENU_BTN_SFX)
	$Settings.is_visible = true
	$Settings/SettingsTree.show()
	Fullscreen.hide_pause_menu()
	get_parent().find_node("Slots").hide_all()
# ------------------------------------------------------------------------------
