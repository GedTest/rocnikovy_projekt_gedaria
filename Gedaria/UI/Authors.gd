extends Sprite

const MENU_BTN_SFX = preload("res://sfx/klik_do_menu_i_z_menu.wav")
const VLAD_RUN_SFX = preload("res://sfx/vladimir_run.wav")

onready var arr_texts = { 
	"back":$Back,
	"thanks":$Thanks,
	"for_sound":$HBoxContainer/VBoxContainer2/Label,
	"streamers":$StreamersNYoutubers
}

var is_done_once = false


func _process(delta):
	if not is_done_once and self.visible:
		$AnimationPlayer.play("Credits")
		is_done_once = true
		Languages.translate(arr_texts, Global.prefered_language)
		
	if AudioManager.is_playing_sfx(VLAD_RUN_SFX):
		AudioManager.stop_sfx(VLAD_RUN_SFX)
		
	if Input.get_mouse_mode():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
# ------------------------------------------------------------------------------

func _on_button_pressed_open(link):
	OS.shell_open(link)
# ------------------------------------------------------------------------------
func _on_Back_pressed():
	AudioManager.play_sfx(MENU_BTN_SFX)
	is_done_once = false
	self.hide()
	
	if self.get_parent().filename != "res://Level/MainMenu/MainMenu.tscn":
		get_tree().change_scene("res://Level/MainMenu/MainMenu.tscn")
