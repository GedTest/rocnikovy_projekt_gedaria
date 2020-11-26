extends StaticBody2D

class_name Branch, "res://Level/Prologue/branch.png"
onready var leaf_path = preload("res://Level/Prologue/Leaves.tscn")
var cracks : int = 0
var timer = null

func _ready():
	timer = get_tree().create_timer(0.0)
# ------------------------------------------------------------------------------
func _process(delta):
	var leaf = leaf_path.instance()
	
	if cracks >= 3:
		cracks = 0
	# animation falling
	# spawn leaf
		add_child(leaf)
		
	# branch destroys
		$Area2D/CollisionShape2D.disabled = true
		$Area2D2/CollisionShape2D.disabled = true
		$CollisionShape2D.disabled = true
		$Sprite.hide()
	
		if timer.time_left <= 0.0:
			timer = get_tree().create_timer(3.5)
			yield(timer, "timeout")
			$Area2D/CollisionShape2D.disabled = false
			$Area2D2/CollisionShape2D.disabled = false
			$CollisionShape2D.disabled = false
			$Sprite.show()
# ------------------------------------------------------------------------------
func _on_Branch_body_entered(body):
	cracks += 1
