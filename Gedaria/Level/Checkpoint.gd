extends Area2D


var has_checked = false

func _ready():
	yield(get_tree().create_timer(0.25), "timeout")
	if has_checked:
		$AnimationPlayer.play("CHECKPOINT")
# ------------------------------------------------------------------------------

func _on_Checkpoint_body_entered(body):
	if body.get_collision_layer_bit(1):
		if not has_checked:
			has_checked = true
			$AnimationPlayer.play("CHECKPOINT")
		SaveLoad.last_saved_slot = "slot_4"
		SaveLoad.save_to_file(4)
# ------------------------------------------------------------------------------

func save(): # SAVE VARIABLES IN DICTIONARY
	return { "has_checked":has_checked }
