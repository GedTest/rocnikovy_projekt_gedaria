extends RigidBody2D

var player = null

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		var a = body.position
		var b = self.position
		var direction = b.direction_to(a).x
		
		player = body
		if abs(direction) > 0.5:
			$AdvancedTween.play(0.5, body.position.x, body.position.x + (200*direction))
# ------------------------------------------------------------------------------

func _on_AdvancedTween_advance_tween(sat):
	if player:
		player.position.x = sat
# ------------------------------------------------------------------------------
