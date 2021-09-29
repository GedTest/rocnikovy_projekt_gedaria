class_name Branch, "res://Level/Prologue/branch.png"
extends StaticBody2D


const MAX_CRACKS = 2
const BRANCH_SFX = preload("res://sfx/branch.wav")
const BRANCH_FALL_SFX = preload("res://sfx/branch_fall.wav")

var cracks = 0
var timer = null
var is_don_once = false

onready var LeafPath = preload("res://Level/Prologue/Leaf.tscn")


func _ready():
	timer = get_tree().create_timer(0.0)
# ------------------------------------------------------------------------------

func _process(delta):
	var leaf = LeafPath.instance()
	
	if cracks == 1 and not is_don_once:
		$AnimationPlayer.play("crack")
		AudioManager.play_sfx(BRANCH_SFX, 1)
		is_don_once = true
	
	if cracks >= MAX_CRACKS:
		is_don_once = false
		cracks = 0
	# spawn leaf
		self.add_child(leaf)
		
	# branch destroys
		$Area2D/CollisionShape2D.disabled = true
		$Area2D2/CollisionShape2D.disabled = true
		$CollisionShape2D.disabled = true
		$AnimationPlayer.play("fall")
		
		if timer.time_left <= 0.0:
			timer = get_tree().create_timer(0.9)
			yield(timer, "timeout")
			AudioManager.play_sfx(BRANCH_FALL_SFX, 0)
			
			if timer.time_left <= 0.0:
				timer = get_tree().create_timer(2.6)
				yield(timer, "timeout")
				$Area2D/CollisionShape2D.disabled = false
				$Area2D2/CollisionShape2D.disabled = false
				$CollisionShape2D.disabled = false
				$AnimationPlayer.play("setup")
				cracks = 0
# ------------------------------------------------------------------------------

func _on_Branch_body_entered(body):
	if body.get_collision_layer_bit(1):
		$Area2D.disconnect("body_entered", self, "_on_Branch_body_entered")
	cracks += 1
# ------------------------------------------------------------------------------

func _on_Branch_body_exited(body):
	yield(get_tree().create_timer(0.25), "timeout")
	$Area2D.connect("body_entered", self, "_on_Branch_body_entered")
# ------------------------------------------------------------------------------
