extends RigidBody2D


var damage = 2
var direction
var closest_enemy


func _ready():
	closest_enemy = get_parent().closest_enemy
# ------------------------------------------------------------------------------
	
func _physics_process(delta):
	direction = position - closest_enemy
	add_central_force(-direction / Vector2(10000,10000))
#-------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(2):
		body = body if body.name != "Shield" else body.get_parent()
		body.health -= damage
		$Timer.start()
# ------------------------------------------------------------------------------

func _on_Timer_timeout():
	queue_free()
