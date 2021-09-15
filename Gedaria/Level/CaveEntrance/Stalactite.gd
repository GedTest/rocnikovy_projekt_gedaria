extends Sprite


var damage = 1
var arr_collision_shapes = [
	"res://Level/CaveEntrance/st_coll1.tres","res://Level/CaveEntrance/st_coll2.tres",
	"res://Level/CaveEntrance/st_coll1.tres","res://Level/CaveEntrance/st_coll4.tres",
	"res://Level/CaveEntrance/st_coll5.tres","res://Level/CaveEntrance/st_coll6.tres",
	"res://Level/CaveEntrance/st_coll7.tres","res://Level/CaveEntrance/st_coll8.tres",
	"res://Level/CaveEntrance/st_coll9.tres","res://Level/CaveEntrance/st_coll10.tres",
	"res://Level/CaveEntrance/st_coll11.tres",
]


func _ready():
	$Area2D/CollisionShape2D.shape = load(arr_collision_shapes[self.frame])
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		body.hit(damage)
# ------------------------------------------------------------------------------

func _on_Area2D2_body_entered(body):
	if body.get_collision_layer_bit(7):
		body.call_deferred("queue_free")
