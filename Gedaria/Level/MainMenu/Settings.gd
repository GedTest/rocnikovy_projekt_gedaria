extends CanvasLayer


var is_visible = false


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

func _on_Slider_value_changed(value):
	var percentage = value if value > 0 else 0
	var master_sound = AudioServer.get_bus_index("Master")
	
	var is_muted = true if percentage == 0 else false
	AudioServer.set_bus_mute(master_sound, is_muted)

	AudioServer.set_bus_volume_db(master_sound, (percentage/2)-30)
	$AudioSettings/HBoxContainer/percentage.text = str(percentage) + "%"
# ------------------------------------------------------------------------------

func _on_Slider2_value_changed(value):
	var percentage = value if value > 0 else 0

	var ui = self.get_parent().find_node("UserInterface")
	ui.find_node("MusicPlayer").volume_db = (percentage/2)-30
	$AudioSettings/HBoxContainer2/percentage.text = str(percentage) + "%"
# ------------------------------------------------------------------------------

func _on_Language_Back_pressed():
	$Languages.hide()
	$SettingsTree.show()
# ------------------------------------------------------------------------------

func _on_SettingsTree_Close_pressed():
	Fullscreen.hide_pause_menu()
	self.hide_all()
# ------------------------------------------------------------------------------

func _on_Audio_Back_pressed():
	$AudioSettings.hide()
	$SettingsTree.show()
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
