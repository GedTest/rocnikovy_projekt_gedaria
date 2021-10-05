
extends Sprite

const KEY_ICON = "res://Level/Key.png"
const LONG_KEY_ICON = "res://Level/LongKey.png"

export(String, "throwing",
				"raking_out_leaves_horizontal",
				"attack",
				"heavy_attack",
				"shooting",
				"raking",
				"wind",
				"pause",
				"interaction",
				"blocking",
				"crouch",
				"jump",
				"quick_save"
)var text
export (bool) var requires_input = true
export (bool) var is_interactable = true 

export(int) var font_size = 30
export(Vector2) var text_field_size = Vector2(570, 215)
export(Vector2) var text_field_pos = Vector2(-287, -108)

var small_pos_y = -108
var small_size_y = 198
var big_pos_y = -125
var big_size_y = 290

var can_interact = false
var has_two_inputs = false
var can_carousel = false
var part = 0

var arr_texts = {}
var timer = null


func _ready():
	timer = self.get_tree().create_timer(0.0)
	if self.text == "raking" or self.text == "shooting" or self.text == "throwing":
		has_two_inputs = true
# ------------------------------------------------------------------------------

func _process(delta):
	if can_interact and (Input.is_action_just_pressed("interact") or not requires_input):
		if requires_input:
			$InteractIcon.hide()
		if self.text == "raking" or self.text == "heavy_attack":
			can_carousel = true
		self.show_text()
		
	if can_carousel:
		self.carousel()
# ------------------------------------------------------------------------------

func _on_Area_body_entered(body):
	if body.get_collision_layer_bit(1) and is_interactable:
		if self.text == "raking" or self.text == "heavy_attack":
			part = 1
		
		can_interact = true
		if requires_input:
			self.wrap_intreaction_text($InteractIcon/Label)
			$InteractIcon.show()
# ------------------------------------------------------------------------------

func _on_Area_body_exited(body):
	if body.get_collision_layer_bit(1):
		can_interact = false
		can_carousel = false
		$Sprite.hide()
		if requires_input:
			$InteractIcon.hide()
# ------------------------------------------------------------------------------

func show_text():
	var keys = KeyBinding.get_current_keys(true)
	
	if self.text == "interaction":
		return
	
	var values = {
		"crouch":{
			"frame":0,"key_pos":Vector2(-224, -57),"icon":true,"icon_frame":2,
			"key_text":keys["crouch"],"key_font":90
		},
		"jump":{
			"frame":0,"key_pos":Vector2(-224, -57),"icon":true,"icon_frame":0,
			"key_text":keys["jump"],"key_font":82
		},
		"shooting":{ 
			"frame":1,"key_pos":Vector2(-260, -71),
			"key_text":keys["shoot"]+"+"+keys["attack"],"key_font":76
		},
		"wind":{ "frame":2 },
		"raking_out_leaves_horizontal":{
			"frame":3,"key_pos":Vector2(-176.897, -62.24),
			"key_text":keys["rake"],"key_font":83
		},
		"pause":{ 
			"frame":4,"key_pos":Vector2(-224.255, -65.239),
			"key_text":keys["pause"],"key_font":90
		},
		"attack":{
			"frame":5,"key_pos":Vector2(-220, -65.239),
			"key_text":keys["attack"],"key_font":82
		},
		"throwing":{
			"frame":6,"key_pos":Vector2(-260, -71),
			"key_text":keys["shoot"]+"+"+keys["attack"],"key_font":76
		},
		"blocking":{
			"frame":7,"key_pos":Vector2(-190, -65.239),
			"key_text":keys["block"],"key_font":82
		},
		"heavy_attack":{
			"frame":8,"key_pos":Vector2(-224, -39),"key_font":70,
			"key_text":keys["heavy_attack"],"label_font":44,
			"label_pos":Vector2(-161.953, -117.328)
		},
		"raking":{
			"frame":11,"key_pos":Vector2(-210, -100),
			"key_text":str(keys["rake"])+" + "+str(keys["right"]),"key_font":76
		},
		"quick_save":{
			"frame":0,"key_pos":Vector2(0, 0),"icon":false,"icon_frame":0,
			"key_text":"","key_font":26,
		}
	}
		
	$Sprite.show()
	$Sprite.frame = values[self.text]["frame"]
	if values[self.text].keys().size() == 1:
		return
	
	$Sprite/Label.rect_position = values[self.text]["key_pos"]
	$Sprite/Label.text = values[self.text]["key_text"] if values[self.text]["key_text"] != "Escape" else "Esc"
	$Sprite/Label.rect_size = Vector2(329, 131)
	$Sprite/Label.get_font("font").size = values[self.text]["key_font"]
	
	if "icon" in values[self.text].keys():
		$Sprite/Icon.visible = values[self.text]["icon"]
		$Sprite/Icon.frame = values[self.text]["icon_frame"]
	
	if self.text == "heavy_attack":
		$Sprite/Label2.show()
		$Sprite/Label2.rect_position = values[self.text]["label_pos"]
		$Sprite/Label2.get_font("font").size = values[self.text]["label_font"]
		$Sprite/Mouse.position = Vector2(-87, 25)
	
	self.wrap_text(values[self.text]["key_text"], $Sprite/Label)
	
	if self.text == "quick_save":
		arr_texts = {"quick_save":$Sprite/Label}
		$Sprite/Label.rect_position = Vector2(-165, -75)
		Languages.translate(arr_texts, Global.prefered_language)
# ------------------------------------------------------------------------------

func wrap_text(key_text, label):
	$Sprite/Mouse.hide()
	$Sprite/Mouse2.hide()
	if "BUTTON_" in key_text:
		var button_counter = 0
		var result = ""
		var is_first = true
		
		for string in key_text.split("+"):
			if not "BUTTON_" in string:
				result += string
				if is_first and has_two_inputs:
					result += "+"
					is_first = false
			else:
				button_counter += 1
				# change icon texture decided on LEFT or RIGHT mouse button
				var side = string.split("_")[1]
				$Sprite/Mouse.frame = 0 if side == "LEFT" else 1
				$Sprite/Mouse.show()
				var pos = Vector2(-87, 25) if self.text == "heavy_attack" else Vector2(0, 0)
				if self.text == "attack":
					pos = Vector2(-87, 0)
				$Sprite/Mouse.position = pos
		
		if button_counter == 2:
			$Sprite/Mouse2.show()
			$Sprite/Mouse2.frame = 0
			$Sprite/Mouse.frame = 1
		label.text = result
	
	if label.text.length() > 2:
		var offset = 0
		var size_offset = 3 if self.text == "raking" else 8
		var max_length = 9 if self.text == "raking" else 6
		if has_two_inputs and self.text != "raking":
			max_length = 5
		
		for i in range(label.text.length()-2):
			if label.text.length() > max_length:
				offset = 8 if self.text == "raking" else 12
				if has_two_inputs and self.text != "raking":
					offset = 4
					size_offset = 5

			if label == $InteractIcon/Label:
				offset = 40
			label.get_font("font").size = label.get_font("font").size-size_offset
			label.rect_position.x = label.rect_position.x-offset
# ------------------------------------------------------------------------------

func wrap_intreaction_text(label):
	label.get_font("font").size = 90
	label.rect_size = Vector2(60, 87)
	label.rect_position = Vector2(-209, -33)
	var keys = KeyBinding.get_current_keys(true)
	label.text = keys["interact"]
	self.wrap_text(keys["interact"], label)
# ------------------------------------------------------------------------------

func carousel():
	if self.text == "heavy_attack":
		var keys = KeyBinding.get_current_keys(true)
		if part == 1:
			$Sprite.frame = 8
			arr_texts = {"heavyattack":$Sprite/Label2}
			Languages.translate(arr_texts, Global.prefered_language)
			$InteractIcon.show()
			$Sprite/Mouse.visible = true if "BUTTON_" in keys["heavy_attack"] else false
			if "BUTTON_" in keys["heavy_attack"]:
				$Sprite/Label.text = "" 
		elif part == 2:
			$Sprite.frame = 9
			arr_texts = {"breaks_shield":$Sprite/Label2}
			Languages.translate(arr_texts, Global.prefered_language)
			$Sprite/Label.text = ""
			$Sprite/Mouse.hide()
			$InteractIcon.show()
			
		elif part == 3:
			$Sprite.frame = 10
			arr_texts = {"limited_by":$Sprite/Label2}
			Languages.translate(arr_texts, Global.prefered_language)
			$Sprite/Label.text = ""
			$Sprite/Mouse.hide()
			$InteractIcon.show()
			part = 0
		
	elif self.text == "raking":
		if part == 1:
			$Sprite.frame = 11
			$InteractIcon.show()
			$Sprite/Label.show()
		elif part == 2:
			$Sprite.frame = 12
			$InteractIcon.show()
			$Sprite/Label.hide()
			$Sprite/Mouse.hide()
			$Sprite/Mouse2.hide()
		elif part == 3:
			$Sprite.frame = 13
			$InteractIcon.show()
			$Sprite/Label.show()
			part = 0

	if timer.time_left <= 0.0:
		timer = get_tree().create_timer(1.15)
		yield(timer, "timeout")
		part += 1
