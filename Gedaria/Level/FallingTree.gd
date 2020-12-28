extends StaticBody2D

#
#var is_done_once = true
#
#
#func _process(delta):
#	if is_done_once:
#		if get_parent().find_node("Patroller5").health <= 2 and is_done_once:
#			is_done_once = false
#			$AnimationPlayer.play("fall")
#			get_parent().find_node("Vladimir").has_learned_heavy_attack = true
#			yield(get_tree().create_timer(3.0, false), "timeout")
#			get_parent().find_node("Vladimir").is_moving = true
#			get_parent().find_node("Shake").start(5, 0.5, 0.25)

func on_enemy_health_changed():
	$AnimationPlayer.play("fall")
	yield(get_tree().create_timer(3.0, false), "timeout")
	
	get_parent().find_node("Vladimir").is_moving = true
	
	get_parent().find_node("Patroller3").to = 6900
	get_parent().find_node("Patroller4").to = 6900
	get_parent().arr_patrollers.erase(get_parent().find_node("Patroller5"))
	get_parent().find_node("Patroller5").queue_free()
	
	get_parent().find_node("Shake").start(5, 0.5, 0.25)
