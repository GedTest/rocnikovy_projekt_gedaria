extends Node2D


var transition = Tween.TRANS_SINE
var easing = Tween.EASE_OUT_IN
var amplitude = 0
var zoom = 0

onready var camera = $Camera2D


func start(ampl = 16, dur = 0.2, freq = 15.0, zoom = Vector2(1,1), pos = Vector2(0,0), trans = Tween.TRANS_SINE, eas = Tween.EASE_OUT_IN):
	self.amplitude = ampl
	$Duration.wait_time = dur
	$Frequency.wait_time = freq
	self.zoom = zoom
	self.transition = trans
	self.easing = eas
	self.position = pos
	
	$Duration.start()
	$Frequency.start()
	shake()
# ------------------------------------------------------------------------------

func shake():
	var random = Vector2()
	random.x = rand_range(-amplitude, amplitude)
	random.y = rand_range(-amplitude, amplitude)
	camera.zoom = zoom
	#camera.position.y = 600
	
	$Tween.interpolate_property(camera,"offset",camera.offset,random,$Frequency.wait_time,transition,easing)
	$Tween.start()
# ------------------------------------------------------------------------------

func _on_Frequency_timeout():
	shake()
# ------------------------------------------------------------------------------

func reset():
	camera.position.y = 540
	camera.zoom = Vector2(1, 1)
	$Tween.interpolate_property(camera,"offset",camera.offset,Vector2(0,0),$Frequency.wait_time,transition,easing)
	$Tween.start()
# ------------------------------------------------------------------------------

func _on_Duration_timeout():
	reset()
	$Frequency.stop()
