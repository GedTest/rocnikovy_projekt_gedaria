extends StaticBody2D


var number_of_piles = 0
var prev_number = 0


func _process(delta):
	if number_of_piles != prev_number:
		prev_number = number_of_piles
		if number_of_piles == 1:
			get_parent().get_node("AnimationPlayer").play("ELEVATOR_1_LEAF")
		elif number_of_piles == 2:
			get_parent().get_node("AnimationPlayer").play("ELEVATOR_2_LEAVES")
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(0) and "PileOfLeaves" in body.name:
		number_of_piles += 1
# ------------------------------------------------------------------------------

func _on_Area2D_body_exited(body):
	if body.get_collision_layer_bit(0) and "PileOfLeaves" in body.name:
		number_of_piles -= 1
		prev_number -= 1
