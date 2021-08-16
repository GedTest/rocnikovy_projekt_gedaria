extends Node2D


var is_yield_paused = false
onready var arr_soldiers = [$soldier2,$soldier3,$soldier4]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Vladimir.has_learned_raking = false
	$Vladimir/Sprite.flip_h = false
	$Vladimir/Camera.position.y = -250
	Fullscreen.hide_elements()
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		$House/wall2.modulate = Color(1,1,1,0.25)
# ------------------------------------------------------------------------------

func _on_Area2D_body_exited(body):
	if body.get_collision_layer_bit(1):
		$House/wall2.modulate = Color(1,1,1,1)
# ------------------------------------------------------------------------------

func _on_DoorArea2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		$Vladimir.is_moving = false
		$Vladimir.velocity = $Vladimir.GRAVITY
		for soldier in arr_soldiers:
			soldier.flip_h = not soldier.flip_h
			
		yield(get_tree().create_timer(1.5), "timeout")
		get_tree().change_scene("res://Level/InTheWood/In the wood.tscn")
