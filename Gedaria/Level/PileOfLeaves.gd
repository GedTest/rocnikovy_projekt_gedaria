extends RigidBody2D

class_name PileOfLeaves

var leafPath = preload("res://Level/Leaf.tscn")
export (int) var value = 3
export (Array) var arrLeafIn = [0,0,0]

var arrChildren = []
var bComplete = false
var bLoad = false
var leaves = 0

func _ready():
	for LeafHolder in get_children():
		if LeafHolder is StaticBody2D:
			arrChildren.append(LeafHolder)
# ------------------------------------------------------------------------------
func _process(delta):
	var sum = 0
	
	if bLoad && !bComplete:
		bLoad = false
		
		for i in range(leaves):
			var Leaf = leafPath.instance()
			get_parent().get_parent().find_node("Leaves").add_child(Leaf)
			Leaf.position = Vector2(position.x-250+(i*100),position.y)
	
	if !bComplete:
		for i in value:
			
			if arrChildren.empty():
				for LeafHolder in get_children():
					if LeafHolder is StaticBody2D:
						arrChildren.append(LeafHolder)
				
			if arrChildren[i].bLeaf:
				arrLeafIn[i] = arrChildren[i].bLeaf
				sum += arrLeafIn[i]
				leaves = sum
				
		if sum == value:
			bComplete = true
			for i in arrChildren:
				SaveLoad.delete_actor(i)
			arrChildren.clear()
			
			self.set_collision_layer_bit(0,true)
			#self.set_collision_mask_bit(1,true)
			yield(get_tree().create_timer(1.0),"timeout")
			self.mode = RigidBody2D.MODE_RIGID
	else:
		self.set_collision_layer_bit(0,true)
		#self.set_collision_mask_bit(1,true)
		self.mode = RigidBody2D.MODE_RIGID
# ------------------------------------------------------------------------------
func Save():
	var savedData = {
		"bComplete":bComplete,
		"bLoad":true,
		"leaves":leaves
	}
	return savedData
# ------------------------------------------------------------------------------
func _on_Grab_body_entered(body, direction):
	if body.get_collision_layer_bit(5):
		self.apply_central_impulse(Vector2(direction * 6000, 0))
