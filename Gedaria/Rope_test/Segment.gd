extends KinematicBody2D
#
#
#onready var previous_node = get_parent().get_node("Segment1")
var velocity = Vector2()
var pos_ex = Vector2()
#
#var arr_previous_node = []
#
#func _process(delta):
#	for node in arr_previous_node:
#		print(node)
#
#	var previous_node_pos = previous_node.pos_ex
#	velocity = (previous_node_pos - global_position)*10 + gravity
#	pos_ex = global_position
#
#	move_and_slide(velocity)
