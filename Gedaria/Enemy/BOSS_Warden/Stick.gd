extends Area2D


var enemy = null
var speed = 10
var starting_pos
var direction
var distance = 1000


func _ready():
	starting_pos = position.x
	enemy = get_parent()
	speed *= 1 if enemy.direction == 1 else -1
# ------------------------------------------------------------------------------

func _process(delta):
	$Sprite.flip_h = true if enemy.direction == 1 else false
	if abs(position.x) > starting_pos+distance:
		speed *= -1
		
	position.x += speed
	rotation_degrees += speed/4
	
	if position.x == starting_pos:
		queue_free()
# ------------------------------------------------------------------------------

func _on_Rake_body_entered(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1) && enemy.has_player:
		enemy.player.hit(enemy.damage + enemy.boost)
	#	enemy.Player.health -= enemy.damage + enemy.boost
		print("Vladimir's health: ", enemy.player.health)
