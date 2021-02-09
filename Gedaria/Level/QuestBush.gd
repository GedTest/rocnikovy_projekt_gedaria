extends AnimatedSprite


func _ready():
	var animation = "happy" if Global.blue_berries == 5 else "sad"
	self.play(animation)
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if Global.level_root().filename == "res://Level/TestLevel.tscn":
		$Label.text = Languages.languages[Global.prefered_language]["bush_quest"]
	elif Global.blue_berries == 5:
		$Label.text = Languages.languages[Global.prefered_language]["bush_thanks"]
		
	if body.get_collision_layer_bit(1):
		$Label.show()
		
		yield(get_tree().create_timer(4.0, false), "timeout")
		$Label.hide()
