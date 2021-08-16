extends StaticBody2D


var is_yield_paused


func _ready():
	is_yield_paused = Global.is_yield_paused
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	$CollisionPolygon2D2.set_deferred("disabled", false)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	if body.get_collision_layer_bit(1):
		yield(get_tree().create_timer(1.0), "timeout")
		self.get_parent().find_node("AnimationPlayer").play("MINECART_MOVES")
