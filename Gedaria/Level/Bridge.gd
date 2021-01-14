extends StaticBody2D


var is_broken = false


func _ready():
	yield(get_tree().create_timer(0.1, false),"timeout")
	$Sprite.frame = 5 if is_broken else 0
	$CollisionPolygon2D.set_deferred("disabled", is_broken)
	$Area2D/CollisionShape2D2.set_deferred("disabled", is_broken)
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	# collision layer 1 = Player
	if body.get_collision_layer_bit(1) or body.get_collision_layer_bit(2):
		is_broken = true
		$Area2D/CollisionShape2D2.set_deferred("disabled", is_broken)
		# BREAKING ANIMATION
		$AnimationPlayer.play("break")
# ------------------------------------------------------------------------------

func save():
	var saved_data = {
		"is_broken":is_broken
	}
	return saved_data
