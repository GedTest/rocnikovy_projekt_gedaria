extends E

class_name Scarecrow, "res://Level/Prologue/scarecrow.png"
var previousHP = 0
var bOnce = true

func _ready():
	previousHP = health
	speed = 0
	StateMachine = $AnimationTree.get("parameters/playback")
# ------------------------------------------------------------------------------
func _process(delta):
	if is_instance_valid(self):
		if health <= 0:
			$Sprite.texture = load("res://Level/Chase/seno.png")
			$CollisionShape2D.disabled = true
			emit_signal("tree_exiting")
			set_process(false)
			disconnect("tree_exiting",get_parent(),"_on_Scarecrow_tree_exiting")
		
		if health != previousHP:
			$Particles2D.emitting = true
		previousHP = health
# ------------------------------------------------------------------------------
