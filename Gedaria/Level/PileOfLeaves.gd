class_name PileOfLeaves
extends RigidBody2D


var LeafPath = preload("res://Level/Leaf.tscn")

export (int) var value = 3
export (Array) var arr_leaves_in = [0, 0, 0]
export (bool) var is_movable = false
export (Vector2) var grab_position = Vector2(150, 50)

var arr_children = []
var is_complete = false
var is_loaded = false
var leaves = 0
var leaf_texture = null


func _ready():
	$GrabLeft/CollisionShape2D.disabled = !is_movable
	$GrabLeft.position = Vector2(-grab_position.x, grab_position.y)
	$GrabLeft.visible = is_movable
	$GrabRight/CollisionShape2D.disabled = !is_movable
	$GrabRight.position = grab_position
	$GrabRight.visible = is_movable
	
	for LeafHolder in get_children():
		if LeafHolder is StaticBody2D:
			arr_children.append(LeafHolder)
# ------------------------------------------------------------------------------

func _process(delta):
	var sum = 0
	
	if is_loaded and !is_complete:
		is_loaded = false
		
		for i in range(leaves):
			print("adding leave ", i)
			var Leaf = LeafPath.instance()
			get_parent().get_parent().find_node("Leaves").add_child(Leaf)
			Leaf.position = Vector2(position.x-250 + (i*100), position.y)
	
	if !is_complete:
		for i in value:
			
			if arr_children.empty():
				for LeafHolder in get_children():
					if LeafHolder is StaticBody2D:
						arr_children.append(LeafHolder)
				
			if arr_children[i].has_leaf:
				
#				if "6" in name:
				build_pile(arr_children[i], sum)
				
				arr_leaves_in[i] = arr_children[i].has_leaf
				sum += arr_leaves_in[i]
				leaves = sum
				
		if sum == value:
			is_complete = true
			for i in arr_children:
				SaveLoad.delete_actor(i)
			arr_children.clear()
			
			self.set_collision_layer_bit(0, true)
			#self.set_collision_mask_bit(1, true)
			yield(get_tree().create_timer(1.0), "timeout")
			self.mode = RigidBody2D.MODE_RIGID
	elif is_movable:
		self.set_collision_layer_bit(0, true)
		#self.set_collision_mask_bit(1, true)
		self.mode = RigidBody2D.MODE_RIGID
	else:
		self.set_collision_layer_bit(0, true)
# ------------------------------------------------------------------------------

func save():
	var saved_data = {
		"is_complete":is_complete,
		"is_loaded":true,
		"leaves":leaves
	}
	return saved_data
# ------------------------------------------------------------------------------

func _on_Grab_body_entered(body, direction):
	if body.get_collision_layer_bit(5):
		self.apply_central_impulse(Vector2(direction * 6000, 0))
# ------------------------------------------------------------------------------

func remove_leaf(leaf_holder):
	leaf_holder.has_leaf = 0
	leaf_holder.find_node("Sprite").texture = null
	leaf_holder.is_empty = true
	leaf_holder.set_collision_layer_bit(3, false)
	leaf_holder.set_collision_mask_bit(3, false)
	leaf_texture = leaf_holder.leaf_texture
# ------------------------------------------------------------------------------

func append_leaf(leaf_holder):
	if leaf_holder.is_empty:
		leaf_holder.has_leaf = 1
		if leaf_texture == null:
			leaf_texture == "res://UI/list_buk.png"
		leaf_holder.find_node("Sprite").texture = load(leaf_texture)
		leaf_holder.is_empty = false
		leaf_holder.set_collision_layer_bit(3, true)
		leaf_holder.set_collision_mask_bit(3, true)
# ------------------------------------------------------------------------------

func build_pile(full_leaf_holder, sum):
	if sum < value-1:
		var row_number = int(full_leaf_holder.get_groups()[1].substr(4, 1))
		var current_row_number = 1 if sum <= 2 else 2
		var empty_leaf_holder = null
		
	#	if sum <= 2:
		if row_number > current_row_number:
			for child in arr_children:
				if child.is_empty:
					empty_leaf_holder = child
					
					remove_leaf(full_leaf_holder)
					append_leaf(empty_leaf_holder)
					
					break
			#print(empty_leaf_holder.name,"  ",full_leaf_holder.get_groups()[1])
#
#	elif sum > 2:
#		current_row_number = 2
#		if row_number > current_row_number:
#			for child in arr_children:
#				if child.is_empty:
#					empty_leaf_holder = child
#
#			remove_leaf(full_leaf_holder)
#			append_leaf(empty_leaf_holder)
