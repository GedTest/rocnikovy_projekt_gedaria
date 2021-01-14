extends AnimatedSprite


var thanks = "Oh děkuji mladíku"
var quest = ""

func _ready():
	quest = $Label.text
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		$Label.text = thanks if Global.blue_berries == 5 else quest
		$Label.show()
		
		var animation = "happy" if Global.blue_berries == 5 else "sad"
		self.play(animation)
		
		yield(get_tree().create_timer(2.0, false), "timeout")
		$Label.hide()
