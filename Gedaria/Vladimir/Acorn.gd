class_name Acorn, "res://UI/zalud.png"
extends Sprite


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.acorn_counter += 1
		
		var ui = Global.level_root().find_node("UserInterface")
		ui.find_node("Acorn").show()
		ui.find_node("AcornCounter").show()
		
		SaveLoad.delete_actor(self)
