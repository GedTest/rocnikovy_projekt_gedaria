extends KinematicBody2D

var Velocity = Vector2(0,0)
var bSlowMotion = false
var speed = 380
var bPlayer = false

func _process(delta):
	if !bPlayer:
		if bSlowMotion:
			Velocity.x = 175
		speed = 30 if !bSlowMotion else 5
		Velocity.x += speed
		if Velocity.x > 380:
			Velocity.x = 380
#	if bPlayer:
#		speed = 0
#		Velocity.x = speed
	Velocity = move_and_slide(Velocity)
# ------------------------------------------------------------------------------
func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		bPlayer = true
		speed = 0
		body.speed = 0
		$AnimatedSprite.play('attack')
		yield(get_tree().create_timer(1.0),"timeout")
		get_tree().change_scene("res://Level/MainMenu/MainMenu.tscn")
# ------------------------------------------------------------------------------
