extends Sprite


func _on_Sprite_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.heavy_attack_counter += 4
		var ui = Global.level_root().find_node("UserInterface")
		var leaf_texture = self.texture.resource_path.split(".png")[0]
			
		ui.set_unique_leaf(leaf_texture)
		SaveLoad.delete_actor(self)
