extends Tween
class_name AdvancedTween


signal advance_tween(sat)

export(Curve) var curve

var start = 0.0
var end = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func play(duration, start_in, end_in):
	start = start_in
	end = end_in
	interpolate_method(self, "interpolate", 0.0, 1.0, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	start()
	
func interpolate(sat):
	emit_signal("advance_tween", start + ((end - start) * curve.interpolate(sat)))
