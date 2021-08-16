extends Control


var can_change_key = false
var can_close = true
var action_string = ""

enum ACTIONS {
	jump, left, crouch, right, attack, heavy_attack, 
	block, rake, fullscreen, interact, shoot, 
	pause
	}
var DEFAULT_KEYS_MAPPING = {}


func _ready():
	if Global.first_entrance:
		DEFAULT_KEYS_MAPPING = self.get_current_keys()
	
	self._set_keys()
# ------------------------------------------------------------------------------

func _set_keys():
	var count_assigned_actions = 0
	for action in ACTIONS:
		get_node("Panel/ScrollContainer/VBoxContainer/" + str(action) + "/Button").set_pressed(false)
		if not InputMap.get_action_list(action).empty():
			var key_text = InputMap.get_action_list(action)[0].as_text()
			if "InputEventMouseButton" in key_text:
				key_text = key_text.split("=")[1].split(",")[0]
			get_node("Panel/ScrollContainer/VBoxContainer/" + str(action) + "/Button").text = key_text
			count_assigned_actions += 1
		else:
			get_node("Panel/ScrollContainer/VBoxContainer/" + str(action) + "/Button").set_text("Not assignednot")
		
		can_close = true if count_assigned_actions == ACTIONS.size() else false
# ------------------------------------------------------------------------------

func _on_Button_pressed(action):
	self._mark_button(action)
# ------------------------------------------------------------------------------

func _mark_button(string):
	can_change_key = true
	action_string = string
	
	for action in ACTIONS:
		if action != string:
			get_node("Panel/ScrollContainer/VBoxContainer/" + str(action) + "/Button").set_pressed(false)
# ------------------------------------------------------------------------------

func _input(event):
	if event is InputEventKey or event is InputEventMouseButton: 
		if can_change_key:
			self._change_key(event)
			can_change_key = false
# ------------------------------------------------------------------------------

func _change_key(new_key):
	#Delete key of pressed button
	if not InputMap.get_action_list(action_string).empty():
		InputMap.action_erase_event(action_string, InputMap.get_action_list(action_string)[0])
	
	#Check if new key was assigned somewhere
	for action in ACTIONS:
		if InputMap.action_has_event(action, new_key):
			InputMap.action_erase_event(action, new_key)
			
	#Add new Key
	InputMap.action_add_event(action_string, new_key)
	
	self._set_keys()
# ------------------------------------------------------------------------------

func reset_keys():
	for key in DEFAULT_KEYS_MAPPING:
		action_string = str(key)
		self._change_key(DEFAULT_KEYS_MAPPING[key])
# ------------------------------------------------------------------------------

func _on_Close_pressed():
	var count_assigned_actions = 0
	for action in ACTIONS:
		if InputMap.get_action_list(action).empty():
			$Label.show()
			$Label.text = "There must be assigned key to this action: "+str(action)
		else:
			count_assigned_actions += 1
	
	can_close = true if count_assigned_actions == ACTIONS.size() else false
	
	if can_close:
		self.hide()
# ------------------------------------------------------------------------------

func get_current_keys(as_text=false):
	var keys = {}
	for action in ACTIONS:
		if not InputMap.get_action_list(action).empty():
			var key_text = InputMap.get_action_list(action)[0]
			
			if as_text:
				key_text = key_text.as_text()
				if "InputEventMouseButton" in key_text:
					key_text = key_text.split("=")[1].split(",")[0]
			
			keys[action] = key_text
	return keys
# ------------------------------------------------------------------------------

func _on_ResetKeys_pressed():
	self.reset_keys()
# ------------------------------------------------------------------------------

func _on_Popup_pressed():
	$Label.hide()
