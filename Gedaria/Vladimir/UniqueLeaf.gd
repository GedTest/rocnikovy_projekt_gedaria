extends Sprite


const REWARD_SFX = preload("res://sfx/reward.wav")

func _on_Sprite_body_entered(body):
	if body.get_collision_layer_bit(1):
		AudioManager.play_sfx(REWARD_SFX, 0, 0, -9)
		body.heavy_attack_counter += 4
		var level = Global.level_root()
		level.find_node("Sign").collected_unique_leaves += 1
		var ui = level.find_node("UserInterface")
		var leaf_texture = self.texture.resource_path.split(".png")[0]
			
		ui.set_unique_leaf(leaf_texture)
		SaveLoad.delete_actor(self)
