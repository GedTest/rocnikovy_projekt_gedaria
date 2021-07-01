extends Button


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
			$Label.text = "save to slot " + str(slot)
		else:
			$Label.text = "overwrite slot " + str(slot)
			
	elif type == "LOAD" and name != "RestartButton":
		if SaveLoad.slots["slot_"+str(slot)].empty():
			$Label.text = "EMPTY"
		else:
			var current_slot = SaveLoad.slots["slot_"+str(slot)]
			var date = current_slot["date"]
			
			$Label.text = current_slot["last_map"].split('/')[3].split('.')[0]
			$Label.text += "\n\nDate: "+str(date["day"])+"."+str(date["month"])+"."+str(date["year"])
			$Label.text += "\nTime: "+str(date["hour"]) + ":" + str(date["minute"])
# ------------------------------------------------------------------------------

func on_pressed():
	match type:
		"SAVE":
			SaveLoad.last_saved_slot = "slot_"+str(slot)
			#SaveLoad.save_to_slot("slot_"+str(slot))
			SaveLoad.save_to_file(slot)
		"LOAD":
			self.disabled = true
			#if !SaveLoad.slots["slot_"+str(slot)].empty():
			Global.is_yield_paused = true
				#SaveLoad.load_from_slot("slot_"+str(slot))
			SaveLoad.load_from_file(slot)
			
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
