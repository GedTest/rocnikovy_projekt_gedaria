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
