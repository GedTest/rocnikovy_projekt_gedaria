extends Area2D


var is_interactable = false


func _on_Letter_body_entered(body):
	$Interact.show()
	is_interactable = true
# ------------------------------------------------------------------------------

func _on_Letter_body_exited(body):
	is_interactable = false
	$Interact.hide()
