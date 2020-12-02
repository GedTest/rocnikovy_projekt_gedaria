extends Area2D


func _on_BridgeArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		var Patroller8 = get_parent().find_node("Patroller8")
		var vladimir = get_parent().find_node("Vladimir")
		
		vladimir.is_moving = false
		Patroller8.find_node("Camera").current = true
		Patroller8.find_node("Sprite").flip_h = true
		Patroller8.is_focused = true
		yield(get_tree().create_timer(4.0, false), "timeout")
		
		vladimir.find_node("Camera").current = true
		vladimir.is_moving = true
		SaveLoad.delete_actor(get_parent().find_node("PebbleProtector"))
		SaveLoad.delete_actor(self)
