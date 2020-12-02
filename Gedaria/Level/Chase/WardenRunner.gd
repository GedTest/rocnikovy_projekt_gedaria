extends KinematicBody2D


var velocity = Vector2(0, 0)
var speed = 380

var is_slow_motion = false
var has_player = false


func _process(delta):
	if !has_player:
		if is_slow_motion:
			velocity.x = 175
		speed = 30 if !is_slow_motion else 5
		velocity.x += speed
		if velocity.x > 380:
			velocity.x = 380
#	if bPlayer:
#		speed = 0
#		velocity.x = speed
	velocity = move_and_slide(velocity)
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		has_player = true
		speed = 0
		body.speed = 0
		$AnimatedSprite.play('attack')
		yield(get_tree().create_timer(1.0), "timeout")
		get_tree().change_scene("res://Level/MainMenu/MainMenu.tscn")
# ------------------------------------------------------------------------------
