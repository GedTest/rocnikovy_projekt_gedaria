extends "res://Enemy/Enemy.gd"

func _process(delta):
	if health <= 0:
		print("dead")
		queue_free()
