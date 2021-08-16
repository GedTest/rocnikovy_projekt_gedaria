extends Control


#var is_yield_paused = true
onready var arr_texts = {
	"start":$StartButton/Label,
	"load":$LoadButton/Label,
	"options":$OptionButton/Label,
	"achievements":$AchievementButton,
	"credits":$CreditsButton/Label,
	"quit":$QuitButton/Label,
	"back":$Back,
	"continue":$StartGame/Continue/Label,
	"new_game":$StartGame/NewGame/Label,
	"audio":$Settings/SettingsTree/HBoxContainer/AudioButton,
	"language":$Settings/SettingsTree/HBoxContainer2/LangButton,
	"close":$Settings/SettingsTree/HBoxContainer3/Close,
	"master_volume":$Settings/AudioSettings/HBoxContainer/MasterPlayerLabel,
	"music_volume":$Settings/AudioSettings/HBoxContainer2/MusicPlayerLabel,
	"reset_keys":$Settings/KeyBinding/ResetKeys,
	"key_binding":$Settings/SettingsTree/HBoxContainer4/BindingButton
}
var latest_slot = -1


func _ready():
	get_tree().paused = false
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	Fullscreen.hide_elements()
	
	
	
	
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
	$Settings/AudioSettings/Back.text = $Back.text
	$Settings/Languages/Back.text = $Back.text
	$Settings/KeyBinding/Close.text = $Settings/SettingsTree/HBoxContainer3/Close.text
# ------------------------------------------------------------------------------

func _on_StartButton_pressed():
	$StartGame.visible = false if $StartGame.visible else true
# ------------------------------------------------------------------------------

func _on_LoadButton_pressed():
	for button in $Slots/LoadButtons.get_children():
		button.update()
	$Slots/LoadButtons.visible = false if $Slots/LoadButtons.visible else true
	$Slots/Close.visible = false if $Slots/Close.visible else true
# ------------------------------------------------------------------------------

func _on_QuitButton_pressed():
	get_tree().quit()
# ------------------------------------------------------------------------------

func _on_OptionButton_pressed():
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
	#			print("d: ",days," h: ",hours," m: ",minutes," s: ",seconds," result: ",result)
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

func _on_CreditsButton_pressed():
	$Authors.show()
	$Back.show()
# ------------------------------------------------------------------------------

func _on_Back_pressed():
	$Authors.hide()
	$Back.hide()
# ------------------------------------------------------------------------------

func _on_TextureButton_pressed():
	$StartGame.hide()
# ------------------------------------------------------------------------------

func _on_Continue_pressed():
	if latest_slot >= 0:
		SaveLoad.load_from_file(latest_slot)
		Fullscreen.show_loading_screen()
# ------------------------------------------------------------------------------

func _on_NewGame_pressed():
	Fullscreen.show_loading_screen()
	var dir_to_remove = Directory.new()
	dir_to_remove.open("user://Saves")
	for file in SaveLoad.paths:
		if dir_to_remove.file_exists(file):
			dir_to_remove.remove(file)
	Global.reset_data()
	yield(get_tree().create_timer(0.1), "timeout")
	
	var new_dir = Directory.new()
	new_dir.make_dir("user://Saves")

	
	get_tree().change_scene("res://Level/InTheWood/In the wood.tscn")
#	get_tree().change_scene("res://Level/Prologue/TutorialLevel.tscn")
#	get_tree().change_scene("res://Level/Chase/ChaseLevel.tscn")
# ------------------------------------------------------------------------------

func _on_instagram_button_pressed(link):
	OS.shell_open(link)


func _on_Back_lang_pressed():
	$Languages.hide()
