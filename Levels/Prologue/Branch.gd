extends StaticBody2D

var cracks = 0
func _process(delta):
	if cracks == 3:
		# animation falling
		# stun enenmy
		# branch destroys
		pass

func _on_Branch_body_entered(body):
	print("Křup křup větvička")
	cracks += 1
	yield(get_tree().create_timer(2),"timeout")
	$CollisionShape2D.disabled = true
	hide()
	yield(get_tree().create_timer(5),"timeout")
	$CollisionShape2D.disabled = false
	show()
