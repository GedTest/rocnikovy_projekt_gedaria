extends CanvasLayer


const FPS = ["10", "24", "30", "60", "120", "144", "240",]
const options = ["Disabled", "2x", "4x", "8x", "16x",]

var is_visible = false


func _ready():
	$VideoSettings/HBoxContainer3/VSyncCheckBox.pressed = OS.vsync_enabled
	$VideoSettings/ConfirmationButton.hide()
	$VideoSettings/Back.disabled = false
	
	var msaa_menu = $VideoSettings/HBoxContainer/MSAADropDown
	self.set_drop_down_menu(msaa_menu, options, get_viewport().msaa)
	
	var fps_menu = $VideoSettings/HBoxContainer2/FPSDropDown
	self.set_drop_down_menu(fps_menu, FPS, FPS.find(str(Engine.target_fps)))
# ------------------------------------------------------------------------------

func set_drop_down_menu(node, options, curent_option):
	for opt in options:
		node.add_item(opt)
	node.selected = curent_option
# ------------------------------------------------------------------------------

func _on_LangButton_pressed():
	$SettingsTree.hide()
	$Languages.show()
# ------------------------------------------------------------------------------

func _on_lang_btn_pressed():
	$SettingsTree.show()
# ------------------------------------------------------------------------------

func _on_AudioButton_pressed():
	$AudioSettings.show()
	$SettingsTree.hide()
# ------------------------------------------------------------------------------

func _on_VideoButton_pressed():
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
	Fullscreen.hide_pause_menu()
	self.hide_all()
# ------------------------------------------------------------------------------

func _on_BindingButton_pressed():
	$KeyBinding.show()
# ------------------------------------------------------------------------------

func hide_all():
	is_visible = false
	$Languages.hide()
	$AudioSettings.hide()
	$KeyBinding.hide()
	$SettingsTree.hide()
# ------------------------------------------------------------------------------

func _on_Back_pressed():
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
	$VideoSettings/Back.disabled = true
	$VideoSettings/ConfirmationButton.show()
# ------------------------------------------------------------------------------

func _on_ConfirmationButton_pressed():
	$VideoSettings/Back.disabled = false
	$VideoSettings/ConfirmationButton.hide()
