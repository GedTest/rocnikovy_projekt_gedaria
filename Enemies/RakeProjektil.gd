extends Area2D
var enemy = null

func _ready():
	enemy = get_parent()
func _on_RakeProjektil_body_entered(body):
	# collision_layer_bit 1 = Player
	if enemy.bThrowing && body.get_collision_layer_bit(1):
		enemy.Player.health -= enemy.damage + enemy.boost
		print("Vladimir's health: ", enemy.Player.health)
