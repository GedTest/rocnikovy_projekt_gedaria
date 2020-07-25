extends E

class_name Scarecrow, "res://Level/Prologue/scarecrow.png"

func _ready():
	speed = 0
	StateMachine = $AnimationTree.get("parameters/playback")
# ------------------------------------------------------------------------------
func _process(delta):
	if health <= 0:
		print("dead")
		queue_free()
