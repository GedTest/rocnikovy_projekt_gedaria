extends RigidBody2D
#
#
#onready var previous_node = get_parent().get_node("RopeHead")
#
var velocity = Vector2()
var pos_ex = Vector2()
#
#
#func _process(delta):
#	var previous_node_pos = previous_node.pos_ex
#	velocity = (previous_node_pos - global_position)*10 + gravity
#	pos_ex = global_position
#
#	move_and_slide(gravity)
