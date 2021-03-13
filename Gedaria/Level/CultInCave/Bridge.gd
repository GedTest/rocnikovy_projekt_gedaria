extends KinematicBody2D


export (int) var start_pos = 0
export (int) var end_pos = 0


# Called when the node enters the scene tree for the first time.
func _process(delta):
	if self.position.x == start_pos:
		$Tween.interpolate_property(self,"position",self.position, Vector2(end_pos, self.position.y),2.0,Tween.TRANS_SINE,Tween.EASE_IN)
	elif self.position.x == end_pos:
		$Tween.interpolate_property(self,"position",self.position, Vector2(start_pos, self.position.y),2.0,Tween.TRANS_SINE,Tween.EASE_IN)
	
	$Tween.start()
