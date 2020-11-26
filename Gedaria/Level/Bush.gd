extends Area2D

var Player = null

# warning-ignore:unused_argument
func _process(delta):
	if Player:
		if Player.bCrouching:
			$Sprite.modulate = Color(0.19,1,0,0.8)
			Player.bHidden = true
		else:
			$Sprite.modulate = Color(0.19,1,0,1)
			Player.bHidden = false

func _on_Bush_body_entered(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		Player = body

func _on_Bush_body_exited(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		Player = null
		body.bHidden = false
		$Sprite.modulate = Color(0.19,1,0,1)
