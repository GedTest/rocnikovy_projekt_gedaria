class_name Pebble, "res://UI/kamen.png"
extends RigidBody2D


const PICK_UP_SFX = preload("res://sfx/pebble.wav")

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1) and body.pebble_counter < 5:
		AudioManager.play_sfx(PICK_UP_SFX, 1, 0, -20)
		body.pebble_counter += 1
		Global.level_root().find_node("UserInterface").update_pebbles(1,"plus",body.pebble_counter)
		SaveLoad.delete_actor(self)
