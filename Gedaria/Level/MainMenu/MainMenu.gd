extends Control


#var is_yield_paused = true
onready var arr_texts = {
	"start":$VBox/VBox/StartButton,
	"load":$VBox/VBox/LoadButton,
	"options":$VBox/VBox/OptionButton,
	"achievements":$VBox/VBox/AchievementButton,
	"credits":$VBox/VBox/CreditsButton,
	"quit":$VBox/VBox/QuitButton,
	"continue":$VBox/VBox/StartButton
}
var latest_slot = -1


func _ready():
	get_tree().paused = false
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	Fullscreen.hide_elements()
	
	
	
	
	var save_game = File.new()
	
	save_game.open(SaveLoad.paths[3], save_game.READ)
	var text = save_game.get_as_text()     # text == file.json
	
	var data = parse_json(text)
	
	yield(get_tree().create_timer(0.05), "timeout")
	
	SaveLoad.slots["slot_"+str(4)] = data

	save_game.close()
	
	latest_slot = self.find_latest_slot(data["date"])
	if latest_slot >= 0:
		$VBox/VBox/StartButton.text = "Continue"
	Languages.translate(arr_texts, Global.prefered_language)
# ------------------------------------------------------------------------------

#func _process(delta):
#	Settings.load_settings()
# ------------------------------------------------------------------------------

func _on_StartButton_pressed():
	if latest_slot >= 0:
		SaveLoad.load_from_file(latest_slot)
	else:
		get_tree().change_scene("res://Level/Chase/ChaseLevel.tscn")
# ------------------------------------------------------------------------------

func _on_LoadButton_pressed():
	for button in $Slots/LoadButtons.get_children():
		button.update()
	$Slots/LoadButtons.show()
	$Slots/Close.show()
# ------------------------------------------------------------------------------

func _on_QuitButton_pressed():
	get_tree().quit()
# ------------------------------------------------------------------------------

func _on_OptionButton_pressed():
	$Languages.show()
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
