extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var player = null
func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		var a = body.position
		var b = self.position
		var direction = b.direction_to(a).x
		print("direction: ",direction)
		player = body
		if abs(direction) > 0.5:
			$AdvancedTween.play(0.5, body.position.x, body.position.x + (200*direction))


func _on_AdvancedTween_advance_tween(sat):
	if player:
		player.position.x = sat
