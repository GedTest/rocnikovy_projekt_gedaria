class_name Scarecrow, "res://Level/Prologue/scarecrow.png"
extends Enemy


var previous_hp = 0
var is_done_once = true


func _ready():
	previous_hp = health
	speed = 0
	state_machine = $AnimationTree.get("parameters/playback")
# ------------------------------------------------------------------------------

func _process(delta):
	if is_instance_valid(self):
		if health <= 0:
			$Sprite.texture = load("res://Level/Chase/seno.png")
			$CollisionShape2D.disabled = true
			emit_signal("tree_exiting")
			set_process(false)
			disconnect("tree_exiting",get_parent(), "_on_Scarecrow_tree_exiting")
		
		if health != previous_hp:
			$Particles2D.emitting = true
		previous_hp = health
# ------------------------------------------------------------------------------
