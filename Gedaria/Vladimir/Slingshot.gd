extends Area2D


const REWARD_SFX = preload("res://sfx/reward.wav")

var offset_y = 35


func _ready():
	$Tween.interpolate_property(self, "position", self.position,\
								Vector2(self.position.x, self.position.y-offset_y),\
								1.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()
# ------------------------------------------------------------------------------

func _on_Slingshot_body_entered(body):
	if body.get_collision_layer_bit(1):
		AudioManager.play_sfx(REWARD_SFX, 0, 0, -9)
		body.has_slingshot = true
		SaveLoad.delete_actor(self)
# ------------------------------------------------------------------------------

func _on_Tween_all_completed():
	# floating loop effect
	offset_y *= -1
	$Tween.interpolate_property(self, "position", self.position,\
								Vector2(self.position.x, self.position.y-offset_y),\
								1.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	
	$Tween.start()
