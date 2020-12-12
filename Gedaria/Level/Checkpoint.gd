extends Area2D


func _on_Checkpoint_body_entered(body):
	if body.get_collision_layer_bit(1):
		SaveLoad.last_saved_slot = "slot_4"
		SaveLoad.save_to_file(4)
