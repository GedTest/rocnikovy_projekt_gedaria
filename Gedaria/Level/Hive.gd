extends StaticBody2D


var BeesPath = preload("res://Level/Bees.tscn")
var PebbleOnGroundPath = preload("res://Vladimir/PebbleOnGround.tscn")

export (Vector2) var extension = Vector2(7000,6085) 

var arr_enemy = []
var timer = null
var closest_enemy = Vector2(999,0)


func _ready():
	$DetectionArea/CollisionShape2D.shape.extents = extension
# ------------------------------------------------------------------------------

func _on_hit_by_stone():
	timer = get_tree().create_timer(0.0)
	if !arr_enemy.empty():
		for enemy in arr_enemy:
			if abs(enemy.position.x - position.x) < closest_enemy.x:
				closest_enemy = enemy.position
		
		if timer.time_left >= 0.0:
			timer = get_tree().create_timer(0.5)
			yield(timer, "timeout")
			var direction = closest_enemy - position
			var bees = BeesPath.instance()
			add_child(bees)
			bees.apply_central_impulse(direction)
	
	elif arr_enemy.empty():
		var pebbleOnGround = PebbleOnGroundPath.instance()
		call_deferred("add_child", pebbleOnGround)
# ------------------------------------------------------------------------------

func _on_DetectionArea_body_entered(body):
	if body.get_collision_layer_bit(2):
		# if there is a enemy in area add him to the array
		arr_enemy.append(body)
# ------------------------------------------------------------------------------

func _on_DetectionArea_body_exited(body):
	if body.get_collision_layer_bit(2):
		arr_enemy.erase(body)
