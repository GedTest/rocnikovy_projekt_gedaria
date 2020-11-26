extends Area2D

export (int) var speed
var distance
var direction
var damage
var startingPosition
var bCanMove = true

func _ready():
	startingPosition = abs(position.x)
	direction = get_parent().direction
	damage = get_parent().damage
	distance = get_parent().FoV
# ------------------------------------------------------------------------------
# warning-ignore:unused_argument
func _process(delta):
	position.x += speed * direction * int(bCanMove)
	
	# WHEN PROJECTILE REACHES BORDER IT VANISHES
	if abs(position.x) > startingPosition + distance:
		queue_free()
# ------------------------------------------------------------------------------
func _on_Projectile_body_entered(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		body.Hit(damage)
		queue_free()
		
	# collision_layer_bit 0 = wall or ground
	elif body.get_collision_layer_bit(0):
		bCanMove = false
		yield(get_tree().create_timer(0.25),"timeout")
		queue_free()
