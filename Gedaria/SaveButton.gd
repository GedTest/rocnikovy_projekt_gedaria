extends Button

export (int, 1, 3) var slot = 1
export (String, "SAVE", "LOAD") var type = "SAVE"

func _ready():
	connect("pressed", self, "on_pressed")
	update()

func update():
	if type == "SAVE":
		if SaveLoad.slots["slot_"+str(slot)].empty():
			text = "save to slot " + str(slot)
		else:
			text = "overwrite slot " + str(slot)
	else:
		if SaveLoad.slots["slot_"+str(slot)].empty():
			text = "EMPTY"
		else:
			text = "load slot " + str(slot)

func on_pressed():
	match type:
		"SAVE":
			SaveLoad.last_saved_slot = "slot_"+str(slot)
			#SaveLoad.save_to_slot("slot_"+str(slot))
			SaveLoad.save_to_file(slot)
		"LOAD":
			if !SaveLoad.slots["slot_"+str(slot)].empty():
				Global.bYieldStop = true
				#SaveLoad.load_from_slot("slot_"+str(slot))
				SaveLoad.load_from_file(slot)
			
	for button in get_tree().get_nodes_in_group("buttons"):
		button.update()
	self.release_focus()
