extends KinematicBody2D

var Velocity = Vector2(0,0)
var bSlowMotion = false
var speed
func _process(delta):
	speed = 0.33 if !bSlowMotion else 3
	Velocity.x += speed
	if bSlowMotion && Velocity.x > speed:
		Velocity.x = speed
	if Velocity.x > 5:
		Velocity.x = 5
	position += Velocity
# ------------------------------------------------------------------------------
func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		get_tree().change_scene("res://Level/MainMenu/MainMenu.tscn")
# ------------------------------------------------------------------------------
