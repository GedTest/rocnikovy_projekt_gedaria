extends KinematicBody2D

var Velocity = Vector2(0,0)
var bSlowMotion = false
var speed = 2.5
var bPlayer = false

func _process(delta):
	if !bPlayer:
		speed = 0.33 if !bSlowMotion else 2.5
		Velocity.x += speed
		if bSlowMotion && Velocity.x > speed:
			Velocity.x = speed
		if Velocity.x > 4.5:
			Velocity.x = 4.5
	if bPlayer:
		speed = 0
		Velocity.x = speed
	position += Velocity
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
