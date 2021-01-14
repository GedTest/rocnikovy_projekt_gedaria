extends Sprite


func _ready():
	var tree_type = self.texture.load_path.split(".")[1]
	var tree_color = tree_type.substr(len(tree_type)-4)
	
	match tree_color:
		"Dark":
			$Leaves.texture = load("res://Level/TreeDarkLeaves.png")
		"ight":
			$Leaves.texture = load("res://Level/TreeLightLeaves.png")
