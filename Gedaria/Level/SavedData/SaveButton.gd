extends Button


const MENU_BTN_SFX = preload("res://sfx/klik_do_menu_i_z_menu.wav")

export (int, 1, 4) var slot = 1
export (String, "SAVE", "LOAD") var type = "SAVE"


func _ready():
	connect("pressed", self, "on_pressed")
	update()
# ------------------------------------------------------------------------------

func update():
	self.check_for_file()
	
	if type == "SAVE":
		if SaveLoad.slots["slot_"+str(slot)].empty():
			$Label.text = "NO DATA"
		else:
			$Label.text = Languages.languages[Global.prefered_language]["overwrite"]
			
	elif type == "LOAD" and name != "RestartButton":
		if SaveLoad.slots["slot_"+str(slot)].empty():
			$Label.text = "NO DATA"
		else:
			var current_slot = SaveLoad.slots["slot_"+str(slot)]
			var date = current_slot["date"]
			
			var level = current_slot["last_map"].split('/')[4].split('.')[0]
			var lang = Global.prefered_language
			var time = Languages.languages[lang]["time"]
			var date_translation = Languages.languages[lang]["date"]
			
			$Label.text = Languages.languages[lang][level]
			$Label.text += "\n\n"+date_translation+str(date["day"])+"."+str(date["month"])+"."+str(date["year"])
			$Label.text += "\n"+time+str(date["hour"]) + ":" + str(date["minute"])
# ------------------------------------------------------------------------------

func on_pressed():
	AudioManager.play_sfx(MENU_BTN_SFX)
	match type:
		"SAVE":
			SaveLoad.last_saved_slot = "slot_"+str(slot)
			#SaveLoad.save_to_slot("slot_"+str(slot))
			SaveLoad.save_to_file(slot)
		"LOAD":
			self.disabled = true
			if not SaveLoad.slots["slot_"+str(slot)].empty():
				Global.is_yield_paused = true
				#SaveLoad.load_from_slot("slot_"+str(slot))
				var save_game = File.new()
				for i in range(4):
					if save_game.file_exists(SaveLoad.paths[i]):
						Fullscreen.show_loading_screen()
						SaveLoad.load_from_file(slot)
						break
			
	for button in get_tree().get_nodes_in_group("buttons"):
		button.update()
	self.release_focus()
# ------------------------------------------------------------------------------

func check_for_file():
	var save_game = File.new()
	
	if not save_game.file_exists(SaveLoad.paths[slot-1]):
		return
	
	save_game.open(SaveLoad.paths[slot-1], save_game.READ)
	var text = save_game.get_as_text()     # text == file.json
	
	var data = parse_json(text)
	
	yield(get_tree().create_timer(0.05), "timeout")
	
	SaveLoad.slots["slot_"+str(slot)] = data

	save_game.close()
