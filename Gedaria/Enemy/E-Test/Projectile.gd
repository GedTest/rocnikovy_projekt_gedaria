extends Area2D


export (int) var speed

var distance
var direction
var damage
var starting_position
var is_moving = true


func _ready():
	var parent = self.get_parent()
	starting_position = abs(position.x)
	direction = parent.direction
	damage = parent.damage
	distance = parent.FoV
	
	if direction is int:
		$Sprite.flip_h = true if direction < 0 else false
		$Particles2D.rotation_degrees = 270 if direction < 0 else 90
	else:
		# SHOOTER IS AIMING IN SECTOR SO DIRETCION IS ANGLE
		$Sprite.flip_h = false
		var angle = parent.find_angle_between(parent.player.position, parent.position)
		$Sprite.rotation_degrees = angle
		$Particles2D.rotation_degrees += angle
# ------------------------------------------------------------------------------

func _physics_process(delta):
	if direction is Vector2:
		position += speed * direction * int(is_moving) * delta
	else:
		position.x += speed * direction * int(is_moving) * delta
	
	# WHEN PROJECTILE REACHES BORDER IT DISAPPEAR
	if abs(position.x) > starting_position + distance:
		self.queue_free()
# ------------------------------------------------------------------------------

func _on_Projectile_body_entered(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		body.hit(damage)
		self.queue_free()
		
	# collision_layer_bit 0 = wall or ground
	elif body.get_collision_layer_bit(0):
		is_moving = false
		yield(get_tree().create_timer(0.25), "timeout")
		self.queue_free()
