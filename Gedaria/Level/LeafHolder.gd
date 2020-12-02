extends StaticBody2D


var LeafPath = preload("res://Level/Leaf.tscn")

export (Vector2) var initial_position = Vector2(0,0)

var has_leaf = 0
var timer = null
var leaf = null
var leaf_reference = null

var is_empty = true
var is_part_of_pile = false


func _ready():
	timer = get_tree().create_timer(0.0)
	is_part_of_pile = true if get_parent().get_class() == "RigidBody2D" else false
	if !is_part_of_pile:
	#	self.add_to_group("persistant")
		print(name," is_empty: ",is_empty)
# ------------------------------------------------------------------------------

func _process(delta):
	if position != initial_position:
		position = initial_position
		
	#if leaf_reference:
	#	$Area2D/Sprite.texture = load(leaf_reference)
	
	var condition = true if $Area2D/Sprite.texture else false
	if is_part_of_pile:
		$CollisionShape2D.disabled = condition
	self.set_collision_layer_bit(0,condition)
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	# collision_layer_bit 3 = Leaves
	if body.get_collision_layer_bit(3):
		if is_empty:
			is_empty = false
			leaf = body
			has_leaf = 1
			#leaf_reference = leaf.find_node('Sprite').texture.load_path
			#print(leaf_reference)
			#print("stex is typeof: ",typeof(leaf_reference))
			
			# if it doesn't have texture = leave is not placed yet
			if !$Area2D/Sprite.texture:
				$Area2D/Sprite.texture = leaf.find_node('Sprite').texture
				SaveLoad.delete_actor(leaf)
				
				self.set_collision_layer_bit(3, true)
				self.set_collision_mask_bit(3, true)
				leaf = null
# ------------------------------------------------------------------------------

func save():
	var saved_data = {
		"is_empty":!is_empty,
		"has_leaf":has_leaf,
		"leaf":leaf,
		#"leaf_reference":leaf_reference
	}
	return saved_data
# ------------------------------------------------------------------------------

func _on_Area2D_area_entered(area):
	if area.get_collision_layer_bit(1) and $Area2D/Sprite.texture and !is_part_of_pile:
		has_leaf = 0
		#leaf_reference = null
		$Area2D/Sprite.texture = null
		var new_leaf = LeafPath.instance()
		
		get_parent().find_node("Leaves").call_deferred("add_child", new_leaf)
		new_leaf.position = Vector2(position.x, position.y-60)
		new_leaf.linear_velocity = Vector2(-75, -200)
		is_empty = true
		
		self.set_collision_layer_bit(3, false)
		self.set_collision_mask_bit(3, false)
