class_name Acorn, "res://UI/zalud.png"
extends Sprite


const REWARD_SFX = preload("res://sfx/acorn.wav")

var offset_y = 35


func _ready():
	self.set_effect()
# ------------------------------------------------------------------------------

func set_effect():
	$effect2.interpolate_property(self, "position", self.position,\
								Vector2(self.position.x, self.position.y-offset_y),\
								1.7, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$effect2.start()
	$effect.interpolate_property(self, "scale", self.scale,\
								Vector2(1.5, 1.5), 0.6,\
								Tween.TRANS_QUAD, Tween.EASE_OUT)
	$effect.interpolate_property(self, "modulate", self.modulate,\
							Color(1.0,1.0,1.0,0.0), 1.0,\
							Tween.TRANS_QUAD, Tween.EASE_OUT)
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		AudioManager.play_sfx(REWARD_SFX, 1, 0, -11)
		body.acorn_counter += 1
		body.collected_acorn_in_level_counter += 1
		$effect.start()
		$Area2D/CollisionShape2D.shape = null
		
		var ui = Global.level_root().find_node("UserInterface")
		ui.find_node("Acorn").show()
		ui.find_node("AcornCounter").show()
# ------------------------------------------------------------------------------

func _on_effect_tween_completed(object, key):
	SaveLoad.delete_actor(self)
# ------------------------------------------------------------------------------

func _on_effect2_tween_all_completed():
	# floating loop effect
	offset_y *= -1
	$effect2.interpolate_property(self, "position", self.position,\
								Vector2(self.position.x, self.position.y-offset_y),\
								1.7, Tween.TRANS_QUAD, Tween.EASE_OUT)
	
	$effect2.start()
