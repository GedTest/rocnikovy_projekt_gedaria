class_name Bush, "res://Level/LightGreenBush2.png"
extends Sprite


var player = null
var arr_collision_size = [
	"res://Level/SmallBush.tres",
	"res://Level/MediumBush.tres",
	"res://Level/LargeBush.tres",
]


func _ready():
	var index = int(self.texture.load_path.split(".")[1][-1])
	$Area2D/CollisionShape2D.shape = load(arr_collision_size[index - 1])
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _process(delta):
	if player:
		if player.is_crouching:
			player.is_hidden = true
			player.find_node("CeilingRay").collide_with_areas = true
		else:
			player.is_hidden = false
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		player = body
# ------------------------------------------------------------------------------

func _on_Area2D_body_exited(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		player = null
		body.is_hidden = false
		body.find_node("CeilingRay").collide_with_areas = false
