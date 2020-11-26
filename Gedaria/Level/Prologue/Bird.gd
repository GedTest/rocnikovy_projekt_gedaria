extends StaticBody2D

signal TimeToFly
const GoalDestination = 1630
var bGoal = false
var bCanFlyAway = false
var MovementSpeed = Vector2(0,0)
var Gravity = 0

func _process(delta):
	position += MovementSpeed
	
	if position.x >= GoalDestination:
		MovementSpeed = Vector2(-2,Gravity)
		Gravity += 0.0125
		if Gravity >= 2.75:
			Gravity = 2.75
			
	elif position.x <= GoalDestination && !bGoal:
		bGoal = true
		Gravity = 0
		MovementSpeed = Vector2(0,0)
		$Area2D/CollisionShape2D.disabled = true
		$CollisionShape2D.disabled = true
	elif bCanFlyAway:
		MovementSpeed += Vector2(-0.125,-0.05)
# ------------------------------------------------------------------------------
func FlyAway():
	bCanFlyAway = true
	MovementSpeed = Vector2(-2,-3.5)
# ------------------------------------------------------------------------------
func _on_Area2D_area_entered(area):
	if area.get_collision_mask_bit(3):
		connect("TimeToFly",self,"FlyAway")
		yield(get_tree().create_timer(1.5),"timeout")
		emit_signal("TimeToFly")
		area.get_parent().cracks = 3
