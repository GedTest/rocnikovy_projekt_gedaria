class_name LeafHolder
extends StaticBody2D


const EMPTY_FRAME = 28
const PARTS_OF_PILE = "res://Level/PileOfLeavesTextures2.png"

var LeafPath = preload("res://Level/Leaf.tscn")

export (Vector2) var initial_position = Vector2(0, 0)
export (Vector2) var direction = Vector2(-1, -1)
export (int) var has_leaf = 0
export (int) var level = 0
export (bool) var is_destroyable = false
export (bool) var is_invincible = false
var can_be_filled = true
export(String, "res://UI/list_buk.png",
	"res://UI/list_břečťan.png","res://UI/list_dub.png",
	"res://UI/list_ginko_biloba.png", "res://UI/list_kopřiva.png",
	"res://UI/list_lipa.png", "res://UI/list_olše.png",
	"res://UI/list_ořech.png", "res://UI/list_javor_červený.png", 
	"res://UI/list_javor_velkolistý.png"
) var texture = "res://UI/list_olše.png"

var leaf = null
var leaf_texture = ""

var is_empty = true
var is_part_of_pile = false


func _ready():
	is_part_of_pile = true if get_parent().get_class() == "RigidBody2D" else false
	self.set_texture()
# ------------------------------------------------------------------------------

func _process(delta):
	if position != initial_position:
		position = initial_position

	var condition = true if has_leaf else false
	if is_part_of_pile:
		$CollisionShape2D.disabled = condition
	self.set_collision_layer_bit(0, condition)
	self.set_collision_mask_bit(2, condition)
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	# collision_layer_bit 3 = Leaves
	if body.get_collision_layer_bit(3) and can_be_filled:
		if is_empty:
			is_empty = false
			has_leaf = 1
			
			# if frame is empty = leave is not placed yet
			if $Area2D/Sprite.frame == EMPTY_FRAME or ((3 * 7) + level):
				self.set_texture()
				
				if is_part_of_pile:
					$Area2D/Sprite.frame = int(get_groups()[1].substr(6, 2))

				SaveLoad.delete_actor(body)
				self.set_collision_layer_bit(3, true)
				self.set_collision_mask_bit(3, true)
					
	
	if body.get_collision_layer_bit(4) and is_destroyable and not is_empty:
		if not is_invincible:
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
	if (area.get_collision_layer_bit(1) and $Area2D/Sprite.frame != EMPTY_FRAME\
	 and not is_part_of_pile) or area.name == "WindBlowerWind":
		if has_leaf and not is_invincible:
			has_leaf = 0
			$Area2D/Sprite.frame = EMPTY_FRAME
			self.spawn_leaf()
			is_empty = true
			
			self.set_collision_layer_bit(3, false)
			self.set_collision_mask_bit(3, false)
			
			if is_destroyable:
				SaveLoad.delete_actor(self)
# ------------------------------------------------------------------------------

func show_leaf():
	is_empty = false
	has_leaf = 1
	leaf_texture = texture
	self.set_texture()
	self.set_collision_layer_bit(3, true)
	self.set_collision_mask_bit(3, true)
# ------------------------------------------------------------------------------

func spawn_leaf():
	var new_leaf = LeafPath.instance()
	new_leaf.name = "from_"+name
	
	var root = Global.level_root()
	root.call_deferred("add_child", new_leaf)
	new_leaf.texture = texture
	
	var new_pos = Vector2(60*direction.x, 60*direction.y)
	new_leaf.position = Vector2(position.x + new_pos.x, position.y+new_pos.y)
	new_leaf.linear_velocity = Vector2(75*direction.x, 200*direction.y)
# ------------------------------------------------------------------------------

func set_texture():
	if is_part_of_pile:
		$Area2D/Sprite.texture = load(PARTS_OF_PILE)
		$Area2D/Sprite.vframes = 7
		$Area2D/Sprite.hframes = 4
		$Area2D/Sprite.frame = (EMPTY_FRAME-1)
		$Area2D/Sprite.scale = Vector2(1.5, 1.5)
	elif not is_part_of_pile:
		$Area2D/Sprite.vframes = 5
		$Area2D/Sprite.hframes = 7
		$Area2D/Sprite.frame = ((randi() % 3) * 7) + level
		self.modulate = Color(1, 1, 1, 1.0)
		if not has_leaf:
			var alpha = 0.4 if level > 1 and level < 5 else 0.75
			self.modulate = Color(1, 1, 1, alpha)
			$Area2D/Sprite.frame = (3 * 7) + level
			
		$Area2D/Sprite.scale = Vector2(1.24, 1.192)
