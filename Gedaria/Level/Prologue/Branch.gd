class_name Branch, "res://Level/Prologue/branch.png"
extends StaticBody2D


onready var LeafPath = preload("res://Level/Prologue/Leaf.tscn")

var cracks : int = 0
var timer = null


func _ready():
	timer = get_tree().create_timer(0.0)
# ------------------------------------------------------------------------------

func _process(delta):
	var leaf = LeafPath.instance()
	
	if cracks >= 3:
		cracks = 0
	# spawn leaf
		self.add_child(leaf)
		
	# branch destroys
		$Area2D/CollisionShape2D.disabled = true
		$Area2D2/CollisionShape2D.disabled = true
		$CollisionShape2D.disabled = true
		$AnimationPlayer.play("fall")
		
		if timer.time_left <= 0.0:
			timer = get_tree().create_timer(3.5)
			yield(timer, "timeout")
			$Area2D/CollisionShape2D.disabled = false
			$Area2D2/CollisionShape2D.disabled = false
			$CollisionShape2D.disabled = false
			$AnimationPlayer.play("setup")
			cracks = 0
# ------------------------------------------------------------------------------

func _on_Branch_body_entered(body):
	cracks += 1
# ------------------------------------------------------------------------------

func shake():
	$Tween.interpolate_property($Sprite, "rotation_degrees", \
								$Sprite.rotation_degrees, 10, \
								1.0, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
	
	$Tween.interpolate_property($Sprite, "rotation_degrees", \
								$Sprite.rotation_degrees, 0, \
								0.5, Tween.TRANS_QUAD,\
								Tween.EASE_OUT_IN, 1.1)
	$Tween.start()
# ------------------------------------------------------------------------------

func _on_Timer_timeout():
	shake()
	$Timer.start(randi() % 5)
