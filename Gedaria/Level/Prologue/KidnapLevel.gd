extends Node2D


var is_yield_paused = false
onready var arr_soldiers = [$soldier2,$soldier3,$soldier4]

func _ready():
	$Vladimir/Sprite.flip_h = false
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
		$Vladimir.velocity.x = 0
		for soldier in arr_soldiers:
			soldier.flip_h = !soldier.flip_h
