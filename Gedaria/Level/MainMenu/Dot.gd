extends Label


export (int) var number = 0
var offset_y = 25


func _ready():
	yield(get_tree().create_timer(number*0.9), "timeout")
	$Tween.interpolate_property(self, "rect_position", self.rect_position,\
						Vector2(self.rect_position.x, self.rect_position.y-offset_y),\
						0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()
# ------------------------------------------------------------------------------

func _on_Tween_tween_all_completed():
	offset_y *= -1
	$Tween.interpolate_property(self, "rect_position", self.rect_position,\
								Vector2(self.rect_position.x, self.rect_position.y-offset_y),\
								0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	
	$Tween.start()
