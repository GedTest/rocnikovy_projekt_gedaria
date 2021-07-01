extends Sprite


const LEAF_IMAGES = [
	"res://UI/list_lipa", "res://UI/list_javor_červený",
	"res://UI/list_olše", "res://UI/list_břečťan",
	"res://UI/list_kopřiva", "res://UI/list_ořech",
	"res://UI/list_buk", "res://UI/list_dub",
	"res://UI/list_ginko_biloba",  
	"res://UI/list_javor_velkolistý"
]


func _on_Sprite_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.heavy_attack_counter += 4
		
		var ui = Global.level_root().find_node("UserInterface")
		ui.find_node("UniqueLeafCounter").show()
		
		var unique_leaf = ui.find_node("UniqueLeaf")
		unique_leaf.show()
		
		var leaf_texture = self.texture.resource_path.split(".png")[0]
		
		if leaf_texture == LEAF_IMAGES[1] or \
			leaf_texture == LEAF_IMAGES[5]:
				unique_leaf.margin_left = 1676
				
		elif leaf_texture == LEAF_IMAGES[4]:
				unique_leaf.margin_left = 1635
			
		unique_leaf.texture_progress = load(leaf_texture + ".png")
		unique_leaf.texture_under = load(leaf_texture + "_50.png")

		
		SaveLoad.delete_actor(self)
