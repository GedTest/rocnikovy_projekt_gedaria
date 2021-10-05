extends StaticBody2D


signal time_to_fly

const GOAL_DESTINATION = 1325
const CROW_SFX = preload("res://sfx/crow.wav")

var is_at_finish = false
var can_fly_away = false

var movement_speed = Vector2(0,0)
var gravity = 0


func _process(delta):
	position += movement_speed
	
	if position.x >= GOAL_DESTINATION:
		movement_speed = Vector2(-2, gravity/2.4)
		gravity += 0.0125
		if gravity >= 2.75:
			gravity = 2.75
			
	elif position.x <= GOAL_DESTINATION and not is_at_finish:
		is_at_finish = true
		gravity = 0
		movement_speed = Vector2(0, 0)
		$Area2D/CollisionShape2D.disabled = true
		$CollisionShape2D.disabled = true
	elif can_fly_away:
		movement_speed += Vector2(-0.125, -0.05)
# ------------------------------------------------------------------------------

func fly_away():
	can_fly_away = true
	movement_speed = Vector2(-2, -3.5)
# ------------------------------------------------------------------------------

func _on_Area2D_area_entered(area):
	if area.get_collision_mask_bit(3):
		connect("time_to_fly", self, "fly_away")
		yield(get_tree().create_timer(1.0), "timeout")
		
		emit_signal("time_to_fly")
		area.get_parent().cracks = 1
