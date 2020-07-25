extends StaticBody2D

onready var arrPosition = [$SpawnPoint,$SpawnPoint2,$SpawnPoint3,$SpawnPoint4,
						$SpawnPoint5,$SpawnPoint6,$SpawnPoint7, $SpawnPoint8]
var Obstacle = preload("res://Level/Chase/Obstacle.tscn").instance()
var UpperObstacle = preload("res://Level/Chase/Obstacle.tscn").instance()
var arrTexture = []

func _ready():
	randomize() # used for purely random seed
	RandSpawn()
	
	arrTexture = [load("res://Level/Chase/seno.png"), load("res://Level/Chase/kameny.png")]
	add_child(Obstacle)
	Obstacle.find_node("Sprite").texture = arrTexture[randi() % 2]
	add_child(UpperObstacle)
# ------------------------------------------------------------------------------
func RandSpawn():
	# Pick random number and spawn obstacle on SpawnPoint
	Obstacle.position = arrPosition[randi() % 4].position
	UpperObstacle.position = arrPosition[randi() % 4 + 4].position
	# prevent from spawning simultaneously on each other in x-axis
	if Obstacle.position.x == UpperObstacle.position.x:
		UpperObstacle.queue_free()
# ------------------------------------------------------------------------------
func _on_Area2D_body_entered(body):  # Spawn next Platform
		# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		$Area2D/CollisionShape2D.set_deferred("disabled", true)
		get_parent().AddFloorTile()
# ------------------------------------------------------------------------------
func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free() # free memory if the platform is out of viewport
# ------------------------------------------------------------------------------
