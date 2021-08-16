extends CanvasLayer

onready var arr_texts = {
	"close":$Close
}


func _ready():
	Languages.translate(arr_texts, Global.prefered_language)
# ------------------------------------------------------------------------------

func _on_Close_pressed():
	$SaveButtons.hide()
	$LoadButtons.hide()
	
	$Close.hide()
# ------------------------------------------------------------------------------

func hide_all():
	$SaveButtons.hide()
	$LoadButtons.hide()
	$Close.hide()
