extends KinematicBody2D


var velocity = Vector2(0, 0)
var speed = 430

var is_slow_motion = false
var has_player = false


func _physics_process(delta):
	if not has_player:
		if is_slow_motion:
			velocity.x = 200
		speed = 10 if not is_slow_motion else 5
		velocity.x += speed
		if velocity.x > 430:
			velocity.x = 430
#	if bPlayer:
#		speed = 0
#		velocity.x = speed
	velocity = move_and_slide(velocity)
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		$AnimatedSprite.play('attack')
		has_player = true
		speed = 0
		body.speed = 0
		body.is_hitted = true
		body.state_machine.travel('HIT')
		yield(get_tree().create_timer(2.5), "timeout")
		get_tree().change_scene("res://Level/MainMenu/MainMenu.tscn")
# ------------------------------------------------------------------------------
