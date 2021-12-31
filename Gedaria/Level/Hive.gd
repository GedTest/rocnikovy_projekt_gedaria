extends StaticBody2D


var BeesPath = preload("res://Level/Bees.tscn")
var PebbleOnGroundPath = preload("res://Vladimir/PebbleOnGround.tscn")

export (Vector2) var extension = Vector2(7000, 5000) 

var arr_enemy = []


func _ready():
	$DetectionArea/CollisionShape2D.shape.extents = extension
# ------------------------------------------------------------------------------

func _on_DetectionArea_body_entered(body):
	if body.get_collision_layer_bit(2):
		arr_enemy.append(body)
# ------------------------------------------------------------------------------

func _on_DetectionArea_body_exited(body):
	if body.get_collision_layer_bit(2):
		arr_enemy.erase(body)
# ------------------------------------------------------------------------------

func _on_HitArea_body_entered(body):
	if body.get_collision_layer_bit(7):
		body.call_deferred("queue_free")
		if not arr_enemy.empty():
			var bees = BeesPath.instance()
			self.call_deferred("add_child", bees)
			
		
		elif arr_enemy.empty():
			var pebbleOnGround = PebbleOnGroundPath.instance()
			call_deferred("add_child", pebbleOnGround)
