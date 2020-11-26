extends StaticBody2D

var beesPath = preload("res://Level/Bees.tscn")
var PebbleOnGroundPath = preload("res://Vladimir/PebbleOnGround.tscn")
var arrEnemy = []
var timer = null
export (Vector2) var extension = Vector2(6400,6085) 
var closestEnemy = Vector2(999,0)

func _ready():
	$DetectionArea/CollisionShape2D.shape.extents = extension

func OnHitByStone():
	timer = get_tree().create_timer(0.0)
	if !arrEnemy.empty():
		for enemy in arrEnemy:
			if abs(enemy.position.x - position.x) < closestEnemy.x:
				closestEnemy = enemy.position
		
		if timer.time_left >= 0.0:
			timer = get_tree().create_timer(0.5)
			yield(timer,"timeout")
			var direction = closestEnemy - position
			var bees = beesPath.instance()
			add_child(bees)
			bees.apply_central_impulse(direction)
	
	elif arrEnemy.empty():
		var pebbleOnGround = PebbleOnGroundPath.instance()
		call_deferred("add_child",pebbleOnGround)

func _on_DetectionArea_body_entered(body):
	if body.get_collision_layer_bit(2):
		# if there is a enemy in area add him to the array
		arrEnemy.append(body)


func _on_DetectionArea_body_exited(body):
	if body.get_collision_layer_bit(2):
		arrEnemy.erase(body)
