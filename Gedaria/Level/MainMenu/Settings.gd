extends CanvasLayer


const FPS = ["10", "24", "30", "60", "120", "144", "240",]
const MSAA = ["Disabled", "2x", "4x", "8x", "16x",]
const LANGUAGES = ["čeština", "english"]

var MENU_BTN_SFX = ""

var is_visible = false


func _ready():
	if Global.level_root().filename == "res://Level/MainMenu/MainMenu.tscn":
		SaveLoad.load_config()
		
	MENU_BTN_SFX = self.get_parent().MENU_BTN_SFX
	$VideoSettings/VSyncCheckBox.pressed = OS.vsync_enabled
	
	var msaa_menu = $VideoSettings/MSAADropDown
	self.set_drop_down_menu(msaa_menu, MSAA, get_viewport().msaa)
	
	var fps_menu = $VideoSettings/FPSDropDown
	self.set_drop_down_menu(fps_menu, FPS, FPS.find(str(Engine.target_fps)))
	
	var lang_menu = $SettingsTree/LangDropDown
	self.set_drop_down_menu(lang_menu, LANGUAGES, LANGUAGES.find(Global.prefered_language))
# ------------------------------------------------------------------------------

func set_drop_down_menu(node, options, curent_option):
	for opt in options:
		node.add_item(opt)
	node.selected = curent_option
# ------------------------------------------------------------------------------

func _on_LangButton_pressed():
	var drop_down = $SettingsTree/LangDropDown
	drop_down.visible = not drop_down.visible
# ------------------------------------------------------------------------------

func _on_lang_btn_pressed():
	$SettingsTree.show()
# ------------------------------------------------------------------------------

func _on_AudioButton_pressed():
	AudioManager.play_sfx(MENU_BTN_SFX)
	$AudioSettings.show()
	$SettingsTree.hide()
	
	if not Global.is_first_entrance(Global.level_root().filename):
		var BUSSES = ["Master", "Music", "SFX"]
		for index in range(3):
			var bus = $AudioSettings.find_node("Slider"+str(index+1))
			bus.value = int(3*(AudioManager.get_volume(BUSSES[index])+15))
# ------------------------------------------------------------------------------

func _on_VideoButton_pressed():
	AudioManager.play_sfx(MENU_BTN_SFX)
	$VideoSettings.show()
	$SettingsTree.hide()
# ------------------------------------------------------------------------------

func _on_Slider_value_changed(value, bus_name):
	var percentage = value if value > 0 else 0
	var music_bus = AudioServer.get_bus_index(bus_name)
	
	var is_muted = true if percentage == 0 else false
	AudioServer.set_bus_mute(music_bus, is_muted)
	
	AudioServer.set_bus_volume_db(music_bus, (percentage/3)-15)
	var label = $AudioSettings.find_node(bus_name).find_node("percentage")
	label.text = str(percentage) + "%"
# ------------------------------------------------------------------------------

func _on_SettingsTree_Close_pressed():
	SaveLoad.save_config()
	AudioManager.play_sfx(MENU_BTN_SFX)
	Fullscreen.hide_pause_menu()
	self.hide_all()
# ------------------------------------------------------------------------------

func _on_BindingButton_pressed():
	AudioManager.play_sfx(MENU_BTN_SFX)
	$KeyBinding.show()
# ------------------------------------------------------------------------------

func hide_all():
	is_visible = false
	$Languages.hide()
	$AudioSettings.hide()
	$KeyBinding.hide()
	$SettingsTree.hide()
# ------------------------------------------------------------------------------

func _on_Close_pressed():
	AudioManager.play_sfx(MENU_BTN_SFX)
	$AudioSettings.hide()
	$VideoSettings.hide()
	$Languages.hide()
	$SettingsTree.show()
# ------------------------------------------------------------------------------

func _on_MenuButton_item_selected(id):
	self.get_viewport().msaa = id
# ------------------------------------------------------------------------------

func _on_FPSDropDown_item_selected(id):
	Engine.target_fps = int(FPS[id])
# ------------------------------------------------------------------------------

func _on_VSyncCheckBox_toggled(button_pressed):
	OS.vsync_enabled = button_pressed
# ------------------------------------------------------------------------------

func _on_LangDropDown_item_selected(id):
	var btn = $SettingsTree/lang_btn 
	btn.language = LANGUAGES[id]
	if not btn.is_connected("pressed", btn, "_on_lang_btn_pressed"):
		btn.connect("pressed", btn, "_on_lang_btn_pressed")
	btn.emit_signal("pressed")
	Languages.translate($KeyBinding.arr_texts, Global.prefered_language)
# ------------------------------------------------------------------------------

func _on_VSyncCheckBox_pressed():
	AudioManager.play_sfx(MENU_BTN_SFX)




func _on_DropDown_item_selected(id, node_name):
	self.find_node(node_name).rect_size.x = 130
