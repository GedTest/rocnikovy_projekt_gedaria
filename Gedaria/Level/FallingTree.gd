extends StaticBody2D


func on_enemy_health_changed():
	$AnimationPlayer.play("fall")
	yield(get_tree().create_timer(3.0, false), "timeout")
	var level = Global.level_root()
	
	level.find_node("Vladimir").is_moving = true
	
	level.find_node("Patroller3").to = 6900
	level.find_node("Patroller4").to = 6900
	level.arr_patrollers.erase(level.find_node("Patroller5"))
	level.arr_enemies.erase(level.find_node("Patroller5"))
	level.find_node("Patroller5").queue_free()
	
	level.find_node("Shake").start(5, 0.5, 0.25)
