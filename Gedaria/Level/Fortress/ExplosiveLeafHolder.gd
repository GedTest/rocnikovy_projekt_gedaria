extends LeafHolder


var player = null
var damage = 2


func _process(delta):
	$CollisionShape2D.set_deferred("disabled", true)
	if $Timer.time_left <= 2.5:
		$Label.text = "2"
		$Label.modulate = Color.orangered
	if $Timer.time_left <= 1.25:
		$Label.text = "1"
		$Label.modulate = Color.orange
	if $Timer.time_left <= 0.3:
		$Label.text = "0"
		$Label.modulate = Color.yellow 
# ------------------------------------------------------------------------------

func _on_Timer_timeout():
	$Explosion.emitting = true
	if player:
		player.hit(damage)
	yield(get_tree().create_timer(0.5), "timeout")
	SaveLoad.delete_actor(self)
# ------------------------------------------------------------------------------

func _on_ExplosiveArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		player = body
# ------------------------------------------------------------------------------

func _on_ExplosiveArea_body_exited(body):
	if body.get_collision_layer_bit(1):
		player = null
# ------------------------------------------------------------------------------

func _on_Tween_tween_completed(object, key):
	$Label.show()
	$Label.text = "3"
	$Label.modulate = Color.red
	$Timer.start()
	is_empty = false
