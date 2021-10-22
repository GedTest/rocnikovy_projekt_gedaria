extends Control


var can_change_key = false
var can_close = true
var action_string = ""

enum ACTIONS {
	jump, left, crouch, right, attack, heavy_attack, 
	block, rake, fullscreen, interact, shoot, 
	pause
	}

var DEFAULT_KEYS_MAPPING = {
	"jump":87,
	"left":65,
	"crouch":83,
	"right":68,
	"attack":1,
	"heavy_attack":2,
	"block":32,
	"rake":16777237,
	"fullscreen":16777254,
	"interact":69,
	"shoot":81,
	"pause":16777217
}

onready var arr_texts = {
	"reset_keys":$ResetKeys,
	"close":$Close,
	"jump":$ScrollContainer/Labels/Label1,
	"left":$ScrollContainer/Labels/Label2,
	"crouch":$ScrollContainer/Labels/Label3,
	"right":$ScrollContainer/Labels/Label4,
	"attack":$ScrollContainer/Labels/Label5,
	"heavyattack":$ScrollContainer/Labels/Label6,
	"blocking":$ScrollContainer/Labels/Label7,
	"rake":$ScrollContainer/Labels/Label8,
	"f11":$ScrollContainer/Labels/Label9,
	"interaction":$ScrollContainer/Labels/Label10,
	"aim":$ScrollContainer/Labels/Label11,
	"pause":$ScrollContainer/Labels/Label12,
}

func _ready():
	if Global.level_root().filename == "res://Level/MainMenu/MainMenu.tscn":
		SaveLoad.load_config()
	self._set_keys()
# ------------------------------------------------------------------------------

func _set_keys():
	var count_assigned_actions = 0
	
	for action in ACTIONS:
		get_node("ScrollContainer/VBoxContainer/" + str(action) + "/Button").set_pressed(false)
		if not InputMap.get_action_list(action).empty():
			var key_text = InputMap.get_action_list(action)[0].as_text()
			if "InputEventMouseButton" in key_text:
				key_text = key_text.split("=")[1].split(",")[0]
				var btn = "r_btn" if "RIGHT" in key_text else "l_btn"
				key_text = Languages.languages[Global.prefered_language][btn]
				
			get_node("ScrollContainer/VBoxContainer/" + str(action) + "/Button").text = key_text
			count_assigned_actions += 1
		else:
			get_node("ScrollContainer/VBoxContainer/" + str(action) + "/Button").set_text("N O N E")
		
		can_close = true if count_assigned_actions == ACTIONS.size() else false
	Languages.translate(arr_texts, Global.prefered_language)
# ------------------------------------------------------------------------------

func _on_Button_pressed(action):
	self._mark_button(action)
# ------------------------------------------------------------------------------

func _mark_button(string):
	can_change_key = true
	action_string = string
	
	for action in ACTIONS:
		if action != string:
			get_node("ScrollContainer/VBoxContainer/" + str(action) + "/Button").set_pressed(false)
# ------------------------------------------------------------------------------

func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		if can_change_key:
			self._change_key(event)
			can_change_key = false
# ------------------------------------------------------------------------------

func _change_key(new_key, action_in_list=action_string):
	#Delete key of pressed button
	if not InputMap.get_action_list(action_in_list).empty():
		InputMap.action_erase_event(action_in_list, InputMap.get_action_list(action_in_list)[0])
	
	#Check if new key was assigned somewhere
	for action in ACTIONS:
		if InputMap.action_has_event(action, new_key):
			InputMap.action_erase_event(action, new_key)
			
	#Add new Key
	InputMap.action_add_event(action_in_list, new_key)
	
	self._set_keys()
# ------------------------------------------------------------------------------

func reset_keys():
	for key in DEFAULT_KEYS_MAPPING:
		action_string = key
		
		var new_input = self.create_input_from_scancode(DEFAULT_KEYS_MAPPING[key])
			
		self._change_key(new_input)
# ------------------------------------------------------------------------------

func create_input_from_scancode(scancode):
	var new_input
	if scancode > 2:
		new_input = InputEventKey.new()
		new_input.scancode = scancode
	else:
		new_input = InputEventMouseButton.new()
		new_input.button_index = scancode
	return new_input
# ------------------------------------------------------------------------------

func _on_Close_pressed():
	AudioManager.play_sfx(get_parent().MENU_BTN_SFX)
	var count_assigned_actions = 0
	for action in ACTIONS:
		if InputMap.get_action_list(action).empty():
			$Control.show()
			$Control/Label.text = "There must be assigned key to this action: "+str(action)
		else:
			count_assigned_actions += 1
	
	can_close = true if count_assigned_actions == ACTIONS.size() else false
	
	if can_close:
		Global.current_key_mapping = []
		for action in ACTIONS:
			if InputMap.get_action_list(action)[0] is InputEventMouseButton:
				Global.current_key_mapping.append(InputMap.get_action_list(action)[0].button_index)
			else:
				Global.current_key_mapping.append(InputMap.get_action_list(action)[0].scancode)
		
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
	AudioManager.play_sfx(get_parent().MENU_BTN_SFX)
	self.reset_keys()
# ------------------------------------------------------------------------------

func _on_Popup_pressed():
	$Control.hide()
