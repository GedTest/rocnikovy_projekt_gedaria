extends CanvasLayer

onready var arr_texts = {
	"close":$Close
}


func translate_close_button():
	Languages.translate(arr_texts, Global.prefered_language)
# ------------------------------------------------------------------------------

func _on_Close_pressed():
	AudioManager.play_sfx(get_parent().MENU_BTN_SFX)
	self.hide_all()
# ------------------------------------------------------------------------------

func hide_all():
	$SaveButtons.hide()
	$LoadButtons.hide()
	$Close.hide()
	$SaveLoadBackground.hide()
