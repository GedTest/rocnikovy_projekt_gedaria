extends Area2D

var bCanInteract = false

func _on_Letter_body_entered(body):
	$Interact.show()
	bCanInteract = true

func _on_Letter_body_exited(body):
	bCanInteract = false
	$Interact.hide()
