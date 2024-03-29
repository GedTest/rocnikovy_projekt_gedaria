extends Node


const HIDDEN = Input.MOUSE_MODE_HIDDEN
const VISIBLE = Input.MOUSE_MODE_VISIBLE

const LEVELS = [
	"res://Level/Chase/ChaseLevel.tscn",
	"res://Level/Prologue/TutorialLevel.tscn",
	"res://Level/Prologue/KidnapLevel.tscn",
	"res://Level/MainMenu/MainMenu.tscn"]

const BOSS_LEVES = [
	"res://Level/Prologue/TutorialLevel.tscn",
	"res://Level/CaveDuel/Cave duel.tscn",
	"res://Level/Fortress/Fortress.tscn",
	"res://Level/MerchantSquirrel.tscn"
]

const BACKGROUNDS = [
	"res://Level/MainMenu/Pause_bg.png", 
	"res://Level/MainMenu/Pause_bg_full.png"
	]

var positions = {
	"0":{"start_pos":Vector2(960, -255),"end_pos":Vector2(960, 100),"rotate":180},
	"1":{"start_pos":Vector2(500, 1355),"end_pos":Vector2(500, 980),"rotate":0},
	"2":{"start_pos":Vector2(-100, 540),"end_pos":Vector2(50, 540),"rotate":0},
	"3":{"start_pos":Vector2(2020, 826),"end_pos":Vector2(1870, 826),"rotate":0},
	"4":{"start_pos":Vector2(2112, -171),"end_pos":Vector2(1828, 86),"rotate":135},
}

var is_sign_entered = false


func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
	
	if Input.is_action_just_pressed("pause") and Global.is_pausable:
		self.pause()
# ------------------------------------------------------------------------------

func _input(event):
	if not Global.level_root().filename in BOSS_LEVES:
		for input in InputMap.get_actions():
			if "quick_slot" in input:
				var number = input[-1]
				if Input.is_action_just_pressed("quick_slot"+number):
					$QuickSave.show()
					$QuickSave.playing = true
					SaveLoad.save_to_file(int(number))
					
					yield(get_tree().create_timer(3.0), "timeout")
					$QuickSave.hide()
					$QuickSave.playing = false
# ------------------------------------------------------------------------------

func pause():
	if not Global.level_root().filename in LEVELS:
		$Timer.start()
		var canvas_layer = Global.level_root().find_node("CanvasLayer")
		var ui = canvas_layer.find_node("UserInterface")
		var settings = canvas_layer.find_node("Settings")
		var key_binding = settings.find_node("KeyBinding")
		var can_close_main_menu = false if key_binding.visible else true
		
		if key_binding.can_close:
			can_close_main_menu = true
		
		canvas_layer.find_node("SaveButton").disabled = Global.level_root().filename in BOSS_LEVES
		
		if not settings.is_visible:
			ui.visible = not ui.visible
			if can_close_main_menu:
				settings.hide_all()
				canvas_layer.find_node("Slots").hide_all()
				for node in canvas_layer.get_children():
					if node is Button:
						node.visible = not node.visible
				
				$TextureRect.texture = load(BACKGROUNDS[0])
				$TextureRect.visible = not $TextureRect.visible
				$PauseMenu.visible = not $PauseMenu.visible
				$Knirocelo.visible = not $Knirocelo.visible
				self.get_tree().paused = not self.get_tree().paused
				
				
				get_viewport().warp_mouse(Vector2(960, 540))
				var cursor_visibility = VISIBLE if self.get_tree().paused else HIDDEN
				if self.get_tree().paused and Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN:
					Input.set_mouse_mode(VISIBLE)
				Input.set_mouse_mode(cursor_visibility)
# ------------------------------------------------------------------------------

func hide_elements():
	$TextureRect.hide()
	$PauseMenu.hide()
	$LoadingScreen.hide()
	$Knirocelo.hide()
	if not Global.level_root().filename in LEVELS:
		Global.level_root().find_node("UserInterface").show()
# ------------------------------------------------------------------------------

func hide_pause_menu():
	if not Global.level_root().filename in LEVELS:
		var canvas_layer = Global.level_root().find_node("CanvasLayer")
		for child in canvas_layer.get_children():
			if child is Button:
				child.visible = not child.visible
		$PauseMenu.visible = not $PauseMenu.visible
		$Knirocelo.visible = not $Knirocelo.visible
		var texture = BACKGROUNDS[0] if $PauseMenu.visible else BACKGROUNDS[1]
		$TextureRect.texture = load(texture)
# ------------------------------------------------------------------------------

func show_loading_screen():
	if not is_sign_entered:
		self.pause()
	Input.set_mouse_mode(HIDDEN)
	
	var arr_texts = { "loading":$LoadingScreen/Label }
	Languages.translate(arr_texts, Global.prefered_language)
	
	yield(get_tree().create_timer(0.25), "timeout")
	var count_letters = len($LoadingScreen/Label.text)
	$LoadingScreen/Label.rect_scale = Vector2(0.9, 0.9) if Global.prefered_language == "polskie" else Vector2.ONE
	$LoadingScreen/Dots.position.x = count_letters*11
	$LoadingScreen.show()
	$LoadingScreen/AnimatedSprite.play()
# ------------------------------------------------------------------------------

func _on_Timer_timeout():
	if self.get_tree().paused:
		$Knirocelo.show()
		rand_seed(randi())
		var index = randi()%4
		var start = positions[str(index)]["start_pos"]
		var end = positions[str(index)]["end_pos"]
		$Knirocelo.rotation_degrees = positions[str(index)]["rotate"]
		
		$Tween.interpolate_property($Knirocelo, "position", start, end, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		$Tween.interpolate_property($Knirocelo, "position", end, start, 1.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 3.5)
		$Tween.start()
	else:
		$Knirocelo.hide()
