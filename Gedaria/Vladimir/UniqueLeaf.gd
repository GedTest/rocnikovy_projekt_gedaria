extends Sprite


func _on_Sprite_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.heavy_attack_counter += 4
		
		var ui = Global.level_root().find_node("UserInterface")
		ui.find_node("UniqueLeafCounter").show()
		ui.find_node("UniqueLeaf").show()
		
		SaveLoad.delete_actor(self)
