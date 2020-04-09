extends Node2D

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	#$Enemy.Move($Enemy.from, $Enemy.to, $Enemy.position)
	#$Enemy2.Move($Enemy2.from, $Enemy2.to, $Enemy2.position)
	#$Enemy4.Move($Enemy4.from, $Enemy4.to, $Enemy4.position)
	$TestEnemy.Move($TestEnemy.from, $TestEnemy.to, $TestEnemy.position)
