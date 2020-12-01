extends Sprite

class_name Bush, "res://Level/LightGreenBush2.png"

var Player = null
var CollisionSize = ["res://Level/SmallBush.tres",
					 "res://Level/MediumBush.tres",
					 "res://Level/LargeBush.tres"]

func _ready():
	var index = int(self.texture.load_path.split(".")[1][-1])
	$Area2D/CollisionShape2D.shape = load(CollisionSize[index - 1])

# warning-ignore:unused_argument
func _process(delta):
	if Player:
		if Player.bCrouching:
			#self.modulate = Color(1,1,1,0.8)
			Player.bHidden = true
		else:
			#self.modulate = Color(1,1,1,1)
			Player.bHidden = false

func _on_Area2D_body_entered(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		Player = body

func _on_Area2D_body_exited(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		Player = null
		body.bHidden = false
		#self.modulate = Color(1,1,1,1)
