extends StaticBody2D


var is_done_once = true
var arr_piles = []


func _process(delta):
	if arr_piles.size() == 1 and is_done_once:
		is_done_once = false
		get_parent().get_node("AnimationPlayer").play("ELEVATOR_1_LEAF")
	elif arr_piles.size() == 2 and is_done_once:
		is_done_once = false
		get_parent().get_node("AnimationPlayer").play("ELEVATOR_2_LEAVES")
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(0) and "PileOf4Leaves" in body.name:
		if !(body in arr_piles):
			arr_piles.append(body)
			is_done_once = true
