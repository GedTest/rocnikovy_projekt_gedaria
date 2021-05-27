extends Area2D


export (int) var speed

var distance
var direction
var damage
var starting_position
var is_moving = true


func _ready():
	starting_position = abs(position.x)
	direction = get_parent().direction
	damage = get_parent().damage
	distance = get_parent().FoV
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _process(delta):
	if direction is Vector2:
		position += speed * direction * int(is_moving)
	else:
		position.x += speed * direction * int(is_moving)
	
	# WHEN PROJECTILE REACHES BORDER IT VANISHES
	if abs(position.x) > starting_position + distance:
		queue_free()
# ------------------------------------------------------------------------------

func _on_Projectile_body_entered(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		body.hit(damage)
		queue_free()
		
	# collision_layer_bit 0 = wall or ground
	elif body.get_collision_layer_bit(0):
		is_moving = false
		yield(get_tree().create_timer(0.25), "timeout")
		queue_free()
