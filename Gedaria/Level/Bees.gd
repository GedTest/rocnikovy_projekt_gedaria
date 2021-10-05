extends RigidBody2D


var arr_enemy = []
var damage = 2
var closest_enemy = Vector2(99999, 0)


func _physics_process(delta):
	if not arr_enemy.empty():
		for enemy in arr_enemy:
			if abs(enemy.position.x - global_position.x) < closest_enemy.x:
				closest_enemy = enemy.global_position

	self.fly_to(closest_enemy)
#-------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(2):
		body = body if body.name != "Shield" else body.get_parent()
		body.health -= damage
		$Timer.start()
# ------------------------------------------------------------------------------

func fly_to(closest_enemy):
	var direction = (closest_enemy - global_position)
	direction /= direction.length()

	if $GroundRay.is_colliding():
		self.apply_central_impulse(Vector2(0, -21))

	direction *= Vector2(0.5, 1.85)
	self.add_central_force(direction)
# ------------------------------------------------------------------------------

func _on_Timer_timeout():
	queue_free()
# ------------------------------------------------------------------------------

func _on_DetectionArea_body_entered(body):
	if body.get_collision_layer_bit(2):
		arr_enemy.append(body)
# ------------------------------------------------------------------------------

func _on_DetectionArea_body_exited(body):
	if body.get_collision_layer_bit(2):
		arr_enemy.erase(body)
