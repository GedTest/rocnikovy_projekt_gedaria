extends Sprite

class_name Acorn, "res://UI/zalud.png"

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		var ui = get_parent().get_parent().find_node("UserInterface")
		ui.find_node("Acorn").show()
		ui.find_node("AcornCounter").show()
		body.acornCounter += 1
		SaveLoad.delete_actor(self)
