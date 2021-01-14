extends StaticBody2D


var LeafPath = preload("res://Level/Leaf.tscn")

export (Vector2) var initial_position = Vector2(0, 0)
export (Vector2) var direction = Vector2(-1, -1)
export (int) var has_leaf = 0
export (bool) var is_destroyable = false
export(String, "res://UI/list_buk.png",
	"res://UI/list_břečťan.png", "res://UI/list_dub.png",
	"res://UI/list_ginko_biloba.png", "res://UI/list_kopřiva.png",
	"res://UI/list_lipa.png", "res://UI/list_olše.png",
	"res://UI/list_ořech.png", "res://UI/4.png", "res://UI/8.png"
) var texture = "res://UI/list_olše.png"

var leaf = null
var leaf_texture = ""

var is_empty = true
var is_part_of_pile = false


func _ready():
	is_part_of_pile = true if get_parent().get_class() == "RigidBody2D" else false
# ------------------------------------------------------------------------------

func _process(delta):
	if position != initial_position:
		position = initial_position
		
	var condition = true if $Area2D/Sprite.texture else false
	if is_part_of_pile:
		$CollisionShape2D.disabled = condition
	self.set_collision_layer_bit(0, condition)
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	# collision_layer_bit 3 = Leaves
	if body.get_collision_layer_bit(3):
		if is_empty:
			is_empty = false
			leaf = body
			has_leaf = 1
			
			# if it doesn't have texture = leave is not placed yet
			if !$Area2D/Sprite.texture:
				leaf_texture = leaf.texture
				$Area2D/Sprite.texture = load(leaf_texture)
				SaveLoad.delete_actor(leaf)
				
				self.set_collision_layer_bit(3, true)
				self.set_collision_mask_bit(3, true)
				leaf = null
	
	if body.get_collision_layer_bit(5) and is_destroyable:
		self.spawn_leaf()
		SaveLoad.delete_actor(self)
# ------------------------------------------------------------------------------

func save():
	var saved_data = {
		"is_empty":is_empty,
		"has_leaf":has_leaf,
		"leaf":leaf,
		"leaf_texture":leaf_texture,
	}
	return saved_data
# ------------------------------------------------------------------------------

func _on_Area2D_area_entered(area):
	if area.get_collision_layer_bit(1) and $Area2D/Sprite.texture and !is_part_of_pile:
		has_leaf = 0
		$Area2D/Sprite.texture = null
		self.spawn_leaf()
		is_empty = true
		
		self.set_collision_layer_bit(3, false)
		self.set_collision_mask_bit(3, false)
# ------------------------------------------------------------------------------

func show_leaf():
	is_empty = false
	has_leaf = 1
	leaf_texture = texture
	$Area2D/Sprite.texture = load(texture)
	self.set_collision_layer_bit(3, true)
	self.set_collision_mask_bit(3, true)
# ------------------------------------------------------------------------------

func spawn_leaf():
	var new_leaf = LeafPath.instance()
	new_leaf.name = "from_"+name
	
	var root = Global.level_root()
	root.find_node("Leaves").call_deferred("add_child", new_leaf)
	new_leaf.texture = leaf_texture
	
	var new_pos = Vector2(60*direction.x, 60*direction.y)
	new_leaf.position = Vector2(position.x + new_pos.x, position.y+new_pos.y)
	new_leaf.linear_velocity = Vector2(75*direction.x, 200*direction.y)
