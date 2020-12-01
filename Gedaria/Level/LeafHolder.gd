extends StaticBody2D

var leafPath = preload("res://Level/Leaf.tscn")
var timer = null
var bLeaf = 0
var Leaf = null
var bCanLeaf = true
var LeafReference = null
var bPartOfPile = false
export (Vector2) var initialPosition = Vector2(0,0)

export(String, "res://UI/list_ořech.png","res://UI/list_buk.png",
		"res://UI/list_kopřiva.png") var predefinedLeaf

func _ready():
	timer = get_tree().create_timer(0.0)
	bPartOfPile = true if get_parent().get_class() == "RigidBody2D" else false
	if !bPartOfPile:
	#	self.add_to_group("persistant")
		print(name," bCanLeaf: ",bCanLeaf)
# ------------------------------------------------------------------------------
func _process(delta):
	if position != initialPosition:
		position = initialPosition
		
	#if LeafReference:
	#	$Area2D/Sprite.texture = load(LeafReference)
	
	var condition = true if $Area2D/Sprite.texture else false
	if bPartOfPile:
		$CollisionShape2D.disabled = condition
	self.set_collision_layer_bit(0,condition)
# ------------------------------------------------------------------------------
func _on_Area2D_body_entered(body):
	# collision_layer_bit 3 = Leaves
	if body.get_collision_layer_bit(3):
		if bCanLeaf:
			bCanLeaf = false
			Leaf = body
			bLeaf = 1
			#LeafReference = Leaf.find_node('Sprite').texture.load_path
			#print(LeafReference)
			#print("stex is typeof: ",typeof(LeafReference))
			
			# if it doesn't have texture = leave is not placed yet
			if !$Area2D/Sprite.texture:
				$Area2D/Sprite.texture = Leaf.find_node('Sprite').texture
				SaveLoad.delete_actor(Leaf)
				
				self.set_collision_layer_bit(3,true)
				self.set_collision_mask_bit(3,true)
				Leaf = null
# ------------------------------------------------------------------------------
func Save():
	var savedData = {
		"bCanLeaf":!bCanLeaf,
		"bLeaf":bLeaf,
		"Leaf":Leaf,
		#"LeafReference":LeafReference
	}
	return savedData


func _on_Area2D_area_entered(area):
	if area.get_collision_layer_bit(1) && $Area2D/Sprite.texture && !bPartOfPile:
		bLeaf = 0
		#LeafReference = null
		$Area2D/Sprite.texture = null
		var leaf = leafPath.instance()
		
		get_parent().find_node("Leaves").call_deferred("add_child",leaf)
		leaf.position = Vector2(position.x,position.y-60)
		leaf.linear_velocity = Vector2(-75,-200)
		bCanLeaf = true
		
		self.set_collision_layer_bit(3,false)
		self.set_collision_mask_bit(3,false)
