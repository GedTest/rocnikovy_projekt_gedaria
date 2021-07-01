extends Sprite


func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		Global.blue_berries += 1
		var ui = Global.level_root().find_node("UserInterface")
		ui.find_node("BlueberryCounter").text = str(Global.blue_berries) + "/5"
		SaveLoad.delete_actor(self)
