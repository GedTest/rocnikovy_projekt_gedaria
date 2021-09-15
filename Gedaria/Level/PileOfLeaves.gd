class_name PileOfLeaves
extends RigidBody2D


const BASE = 3
const LEAF_HOLDER_4_POSITION = Vector2(-43.736, 0)

var LeafPath = preload("res://Level/Leaf.tscn")

export (int) var value = 4
export (Array) var arr_leaves_in = [0, 0, 0, 0]
export (bool) var is_movable = false
#export (Vector2) var grab_position = Vector2(150, 50)

var arr_children = []
var is_complete = false
var is_loaded = false
var leaves = 0
var leaf_texture = null


func _ready():
	$GrabLeft/CollisionShape2D.disabled = not is_movable
	$GrabRight/CollisionShape2D.disabled = not is_movable
	
	for LeafHolder in get_children():
		if LeafHolder is StaticBody2D:
			arr_children.append(LeafHolder)
# ------------------------------------------------------------------------------

func _process(delta):
	var sum = 0
	
	if is_loaded and not is_complete:
		is_loaded = false
		
		for i in range(leaves):
			var Leaf = LeafPath.instance()
			get_parent().get_parent().find_node("Leaves").add_child(Leaf)
			Leaf.position = Vector2(position.x-250 + (i*100), position.y)
	
	if not is_complete:
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
			$Sprite.modulate = Color(1, 1, 1, 1)
			$Sprite.z_index = 0
			
			self.set_collision_layer_bit(0, true)
			#self.set_collision_mask_bit(1, true)
			yield(get_tree().create_timer(1.0), "timeout")
			self.mode = RigidBody2D.MODE_RIGID
	elif is_movable:
		self.set_collision_layer_bit(0, true)
		self.set_collision_layer_bit(10, true)
		#self.set_collision_mask_bit(1, true)
		self.mode = RigidBody2D.MODE_RIGID
		$Sprite.modulate = Color(1, 1, 1, 1)
		$Sprite.z_index = 0
		
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
	if body.get_collision_layer_bit(4):
		self.apply_central_impulse(Vector2(direction * 6000, 0))
# ------------------------------------------------------------------------------

func remove_leaf(leaf_holder):
	leaf_holder.has_leaf = 0
	leaf_holder.is_empty = true
	leaf_holder.set_collision_layer_bit(3, false)
	leaf_holder.set_collision_mask_bit(3, false)
	leaf_texture = leaf_holder.find_node("Sprite").frame
	leaf_holder.find_node("Sprite").frame = LeafHolder.EMPTY_FRAME-1
# ------------------------------------------------------------------------------

func append_leaf(leaf_holder):
	if leaf_holder.is_empty:
		leaf_holder.has_leaf = 1
		leaf_holder.is_empty = false
		leaf_holder.set_collision_layer_bit(3, true)
		leaf_holder.set_collision_mask_bit(3, true)
		if leaf_holder.name == "LeafHolder4":
			leaf_holder.initial_position = LEAF_HOLDER_4_POSITION
		
#		if leaf_texture == null or leaf_texture == LeafHolder.EMPTY_FRAME:
#			leaf_texture = 1
		leaf_holder.find_node("Sprite").frame = leaf_texture
# ------------------------------------------------------------------------------

func build_pile(full_leaf_holder, sum):
	if sum < value-1:
		var index = 1
		for i in full_leaf_holder.get_groups().size():
			if "row" in full_leaf_holder.get_groups()[i]:
				index = i
		
		var row_number = int(full_leaf_holder.get_groups()[index].substr(4, 2))
		var current_row_number = 1 if sum < BASE else 2
		var empty_leaf_holder = null
		
		
		#if sum <= 2:
		var frame = int(full_leaf_holder.get_groups()[index].substr(6, 2))
		full_leaf_holder.find_node("Sprite").frame = frame
		
		if row_number > current_row_number:
			for child in arr_children:
				if child.is_empty:
					empty_leaf_holder = child
					
					remove_leaf(full_leaf_holder)
					append_leaf(empty_leaf_holder)
					
					break
			#print(empty_leaf_holder.name,"  ",full_leaf_holder.get_groups()[1])

#		elif sum > 2:
#			var frame = int(full_leaf_holder.get_groups()[index].substr(6, 2))
#			full_leaf_holder.find_node("Sprite").frame = frame
#			#current_row_number = 2
#			print("now frame is #",frame)
#			if row_number > current_row_number:
#				for child in arr_children:
#					if child.is_empty:
#						empty_leaf_holder = child
#						print(empty_leaf_holder.name)
#
#						remove_leaf(full_leaf_holder)
#						append_leaf(empty_leaf_holder)
#
#						break
