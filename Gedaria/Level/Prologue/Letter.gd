extends Area2D


var is_interactable = false


func _on_Letter_body_entered(body):
	$Interact.text = "E"
	$Text/Label.append_bbcode(Languages.languages[Global.prefered_language]["letter"])
	$Interact.show()
	is_interactable = true
# ------------------------------------------------------------------------------

func _on_Letter_body_exited(body):
	is_interactable = false
	$Interact.bbcode_text = "[center]"
	$Text/Label.bbcode_text = "[center]"
	$Interact.hide()
