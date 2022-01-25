extends Control

const FOREST_MUSIC = preload("res://gedaria_theme1wav.wav")
const MENU_BTN_SFX = preload("res://sfx/klik_do_menu_i_z_menu.wav")

#var is_yield_paused = true
onready var arr_texts = {
	"start":$StartButton/Label,
	"load":$LoadButton/Label,
	"options":$OptionButton/Label,
	"credits":$CreditsButton/Label,
	"quit":$QuitButton/Label,
	"continue":$StartGame/Continue/Label,
	"new_game":$StartGame/NewGame/Label,
	"audio":$Settings/SettingsTree/AudioButton,
	"language":$Settings/SettingsTree/LangButton,
	"close":$Settings/SettingsTree/Close,
	"master_volume":$Settings/AudioSettings/Master/MasterPlayerLabel,
	"music_volume":$Settings/AudioSettings/Music/MusicPlayerLabel,
	"sfx_volume":$Settings/AudioSettings/SFX/SFXPlayerLabel,
	"reset_keys":$Settings/KeyBinding/ResetKeys,
	"key_binding":$Settings/SettingsTree/BindingButton
}
var latest_slot = -1


func _ready():
	AudioManager.play_music(FOREST_MUSIC)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0)
	get_tree().paused = false
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	Fullscreen.hide_elements()
	Languages.translate(arr_texts, Global.prefered_language)
	
	
	var save_game = File.new()
	
	if save_game.file_exists(SaveLoad.paths[3]):
		save_game.open(SaveLoad.paths[3], save_game.READ)
		var text = save_game.get_as_text()     # text == file.json
		
		var data = parse_json(text)
		
		yield(get_tree().create_timer(0.05), "timeout")
		
		SaveLoad.slots["slot_"+str(4)] = data
	
		save_game.close()
		if data:
			latest_slot = self.find_latest_slot(data["date"])
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
# ------------------------------------------------------------------------------

func _process(delta):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Settings/AudioSettings/Close.text = $Settings/SettingsTree/Close.text
	$Settings/VideoSettings/Close.text = $Settings/SettingsTree/Close.text
	$Slots/Close.text = $Settings/SettingsTree/Close.text
	$Settings/KeyBinding/Close.text = $Settings/SettingsTree/Close.text
	$Continue2/Label.text = $StartGame/Continue/Label.text
# ------------------------------------------------------------------------------

func _on_StartButton_pressed():
	AudioManager.play_sfx(MENU_BTN_SFX)
	$StartGame.visible = false if $StartGame.visible else true
# ------------------------------------------------------------------------------

func _on_LoadButton_pressed():
	AudioManager.play_sfx(MENU_BTN_SFX)
	self.disable_buttons()
	for button in $Slots/SaveButtons.get_children():
		button.type = "LOAD"
		button.disabled = false
		button.update()
	$Settings/background.show()
	$Slots/SaveLoadBackground.visible = false if $Slots/SaveLoadBackground.visible else true
	$Slots/SaveButtons.visible = false if $Slots/SaveButtons.visible else true
	$Slots/Close.visible = false if $Slots/Close.visible else true
# ------------------------------------------------------------------------------

func _on_QuitButton_pressed():
	get_tree().quit()
# ------------------------------------------------------------------------------

func _on_OptionButton_pressed():
	AudioManager.play_sfx(MENU_BTN_SFX)
	self.disable_buttons()
	$Settings/background.show()
	$Settings/SettingsTree.show()
# ------------------------------------------------------------------------------

func find_latest_slot(data):
	var default = data["day"]*86400 + data["hour"]*3600 + data["minute"]*60 + data["second"] 
	var latest = 4
	
	for slot in SaveLoad.slots:
		if "date" in SaveLoad.slots[slot].keys():
			var days = SaveLoad.slots[slot]["date"]["day"] * 86400
			var hours = SaveLoad.slots[slot]["date"]["hour"] * 3600
			var minutes = SaveLoad.slots[slot]["date"]["minute"] * 60
			var seconds = SaveLoad.slots[slot]["date"]["second"]
			
			var result = days + hours + minutes + seconds
			if result > default:
				default = result
				latest = int(slot[-1])
				
	return latest
# ------------------------------------------------------------------------------

func _on_VideoPlayer_finished():
	var video_file = $VBoxContainer/VideoPlayer.stream.get_file()
	var VIDEOS = [
		"res://Level/MainMenu/Název_1.ogv", "res://Level/MainMenu/Název_2.ogv", 
		"res://Level/MainMenu/Název_3_1_1.ogv", "res://Level/MainMenu/5_1.ogv", 
		"res://Level/MainMenu/6_1.ogv"
		]
	var index = VIDEOS.find(video_file)
	if index == 4:
		index = -1
	
	if VIDEOS[index+1] == VIDEOS[3] or VIDEOS[index+1] == VIDEOS[4]:
		$VBoxContainer.rect_position = Vector2(52, 0)
		$VBoxContainer.rect_min_size = Vector2(1080, 1080)
		$VBoxContainer.rect_size = Vector2(1080, 1080)
		$VBoxContainer/VideoPlayer.rect_min_size = Vector2(1080, 1080)
		$VBoxContainer/VideoPlayer.rect_size = Vector2(1080, 1080)
	else:
		$VBoxContainer.rect_position = Vector2(52, -140)
		$VBoxContainer.rect_min_size = Vector2(1080, 1400)
		$VBoxContainer.rect_size = Vector2(1080, 1400)
		$VBoxContainer/VideoPlayer.rect_size = Vector2(1080, 1400)
		$VBoxContainer/VideoPlayer.rect_min_size = Vector2(1080, 1400)
	
	$VBoxContainer/VideoPlayer.stream = load(VIDEOS[index+1])
	$VBoxContainer/VideoPlayer.play()
# ------------------------------------------------------------------------------

func disable_buttons():
	$StartButton.disabled = not $StartButton.disabled
	$LoadButton.disabled = not $LoadButton.disabled
	$OptionButton.disabled = not $OptionButton.disabled
	$CreditsButton.disabled = not $CreditsButton.disabled
	$QuitButton.disabled = not $QuitButton.disabled
	$StartGame/NewGame.disabled = not $StartGame/NewGame.disabled
	$StartGame/Continue.disabled = not $StartGame/Continue.disabled
# ------------------------------------------------------------------------------

func _on_CreditsButton_pressed():
	AudioManager.play_sfx(MENU_BTN_SFX)
	$Authors.show()
# ------------------------------------------------------------------------------

func _on_TextureButton_pressed():
	AudioManager.play_sfx(MENU_BTN_SFX)
	$StartGame.hide()
# ------------------------------------------------------------------------------

func _on_Continue_pressed():
	if latest_slot >= 0:
		AudioManager.play_sfx(MENU_BTN_SFX)
		SaveLoad.load_from_file(latest_slot)
		Fullscreen.show_loading_screen()
# ------------------------------------------------------------------------------

func _on_NewGame_pressed():
	AudioManager.play_sfx(MENU_BTN_SFX)
	var dir_to_remove = Directory.new()
	dir_to_remove.open("user://Saves/")
	for file in SaveLoad.paths:
		if "config" in file:
			continue
		if dir_to_remove.file_exists(file):
			dir_to_remove.remove(file)
	Global.reset_data()
	yield(get_tree().create_timer(0.1), "timeout")
	
	var new_dir = Directory.new()
	new_dir.make_dir("user://Saves")
	
	$StartButton.disabled = true
	$LoadButton.disabled = true
	$OptionButton.disabled = true
	$CreditsButton.disabled = true
	$QuitButton.disabled = true
	
	$AnimationPlayer.play("INTRO")
# ------------------------------------------------------------------------------

func _on_LoadingButton_pressed():
	$Slots.hide_all()
	$Settings/background.hide()
	self.disable_buttons()
# ------------------------------------------------------------------------------

func _on_ContinueIntro_pressed():
	$StartButton.disabled = false
	$LoadButton.disabled = false
	$OptionButton.disabled = false
	$CreditsButton.disabled = false
	$QuitButton.disabled = false
	get_tree().change_scene("res://Level/Chase/ChaseLevel.tscn")


func _on_Back_lang_pressed():
	$Languages.hide()

func _on_SettingsClose_pressed():
	$Settings/background.hide()
	self.disable_buttons()

func _on_LoadClose_pressed():
	$Settings/background.hide()
	self.disable_buttons()
