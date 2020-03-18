extends Node2D

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	$Enemy.Move($Enemy.from, $Enemy.to, $Enemy.position)