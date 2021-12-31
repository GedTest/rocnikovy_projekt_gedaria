extends Node2D


const LEAF_HOLDER_PATH = preload("res://Level/LeafHolder.tscn")
const LEAF_PATH = preload("res://Level/Leaf.tscn")
const LEAF_HOLDER_SIZE = Vector2(42, 53)

signal on_completed

export (int) var number_of_levels = 1
export (int) var leaf_holder_per_level = 1
export (int) var leaf_holder_level = 1
export(String, "res://UI/list_buk.png",
	"res://UI/list_břečťan.png","res://UI/list_dub.png",
	"res://UI/list_ginko_biloba.png", "res://UI/list_kopřiva.png",
	"res://UI/list_lipa.png", "res://UI/list_olše.png",
	"res://UI/list_ořech.png", "res://UI/list_javor_červený.png", 
	"res://UI/list_javor_velkolistý.png"
) var texture = "res://UI/list_olše.png"

var level = 0
var counter = 0

var is_completed = false

var already_filled = []

onready var arr_levels = []


func _ready():
	$KillZone.position = Vector2.ZERO
	$KillZone/CollisionShape2D.shape.extents = Vector2.ZERO
	
	for i in range(number_of_levels):
		var node = Node2D.new()
		self.add_child(node)
		node.name = "Level"+str(i)
		arr_levels.push_front(node)
		for j in leaf_holder_per_level:
			var leaf_holder = LEAF_HOLDER_PATH.instance()
			leaf_holder.name = "LeafHolder"+str(j)
			leaf_holder.position = Vector2(90*j, 105*i)
			leaf_holder.initial_position = Vector2(90*j, 105*i)
			leaf_holder.level = leaf_holder_level
			leaf_holder.can_be_filled = false
			leaf_holder.is_invincible = true
			leaf_holder.is_destroyable = false
			if i == number_of_levels-1:
				leaf_holder.can_be_filled = true
			node.add_child(leaf_holder)
# ------------------------------------------------------------------------------

func _process(delta):
	self.fill()
# ------------------------------------------------------------------------------

func falling_leaves():
	var y = -600
	var y_offset = 0
	for i in range(number_of_levels):
		for j in leaf_holder_per_level:
			var leaf = LEAF_PATH.instance()
			leaf.set_collision_mask_bit(0, false)
			self.call_deferred("add_child", leaf)
			leaf.position = Vector2(0, -400)
			
			y_offset = i
			if leaf_holder_per_level > 5 or number_of_levels > 10:
				y_offset = 2.6*i
			leaf.position += Vector2(90*j, (y*y_offset) - j*100)
# ------------------------------------------------------------------------------

func fill():
	var current_level = arr_levels[level].get_children()
	for child in current_level:
		if child.has_leaf and not child in already_filled:
			already_filled.append(child)
			counter += 1
			continue
			
	if counter == leaf_holder_per_level:
		counter = 0
		if level+1 < arr_levels.size():
			level += 1
			$KillZone.position.y -= (LEAF_HOLDER_SIZE.y + 7)
			$KillZone/CollisionShape2D.shape.extents.y += LEAF_HOLDER_SIZE.y
	
			for child in arr_levels[level].get_children():
				child.can_be_filled = true
		else:
			is_completed = true
			if "Cage" in self.get_parent().name:
				self.emit_signal("on_completed")
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		$Area2D/CollisionShape2D.set_deferred("disabled", true)
		var default_size = Vector2(LEAF_HOLDER_SIZE.x*leaf_holder_per_level, LEAF_HOLDER_SIZE.y)
		$KillZone.position = Vector2(LEAF_HOLDER_SIZE.x*leaf_holder_per_level-42, (LEAF_HOLDER_SIZE.y*number_of_levels)+(60*number_of_levels))
		$KillZone/CollisionShape2D.shape.extents = default_size
		self.falling_leaves()
# ------------------------------------------------------------------------------

func _on_KillZone_body_entered(body):
	if body.get_collision_layer_bit(1):
		$KillZone/CollisionShape2D.set_deferred("disabled", true)
		body.die()
# ------------------------------------------------------------------------------
