class_name Acorn, "res://UI/zalud.png"
extends Sprite


func _ready():
	$effect.interpolate_property(self, "scale", self.scale,\
								Vector2(1.5, 1.5), 0.6,\
								Tween.TRANS_QUAD, Tween.EASE_OUT)
	$effect.interpolate_property(self, "modulate", self.modulate,\
							Color(1.0,1.0,1.0,0.0), 1.0,\
							Tween.TRANS_QUAD, Tween.EASE_OUT)
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.acorn_counter += 1
		$effect.start()
		$Area2D/CollisionShape2D.shape = null
		
		var ui = Global.level_root().find_node("UserInterface")
		ui.find_node("Acorn").show()
		ui.find_node("AcornCounter").show()
		
# ------------------------------------------------------------------------------

func _on_effect_tween_completed(object, key):
	SaveLoad.delete_actor(self)
