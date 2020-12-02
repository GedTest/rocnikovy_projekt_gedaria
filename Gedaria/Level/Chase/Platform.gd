extends StaticBody2D


onready var arr_position = [
	$SpawnPoint,$SpawnPoint2,$SpawnPoint3,$SpawnPoint4,
	$SpawnPoint5,$SpawnPoint6,$SpawnPoint7, $SpawnPoint8,
]

onready var Obstacle = preload("res://Level/Chase/Obstacle.tscn")
#var UpperObstacle = preload("res://Level/Chase/Obstacle.tscn").instance()
onready var UpperObstacle = preload("res://Level/Chase/UpperObstacle.tscn")

var arr_texture = []
var obstacle = null
var upper_obstacle = null


func _ready():
	randomize() # used for purely random seed
	
	arr_texture = [load("res://Level/Chase/seno.png"), load("res://Level/Chase/kameny.png")]
	obstacle = Obstacle.instance()
	add_child(obstacle)
	obstacle.find_node("Sprite").texture = arr_texture[randi() % 2]
	
	upper_obstacle = UpperObstacle.instance()
	add_child(upper_obstacle)
	
	rand_spawn()
# ------------------------------------------------------------------------------

func rand_spawn():
	# Pick random number and spawn obstacle on SpawnPoint
	obstacle.position = arr_position[randi() % 4].position
	upper_obstacle.position = arr_position[randi() % 4 + 4].position
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):  # Spawn next Platform
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		$Area2D/CollisionShape2D.set_deferred("disabled", true)
		get_parent().add_floor_tile()
# ------------------------------------------------------------------------------

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free() # free memory if the platform is out of viewport
