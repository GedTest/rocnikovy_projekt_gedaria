class_name Bush, "res://Level/LightGreenBush2.png"
extends Sprite


const BUSH_SFX = preload("res://sfx/schování se do křoví.wav")

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
			player.can_stand_up = false
		else:
			player.is_hidden = false
			player.can_stand_up = true
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		AudioManager.play_sfx(BUSH_SFX)
		player = body
# ------------------------------------------------------------------------------

func _on_Area2D_body_exited(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
#		AudioManager.play_sfx(BUSH_SFX)
		player = null
		var is_crouching_in_another_bush = false
		
		for bush in self.get_parent().get_children():
			if bush.player:
				if not bush.player.can_stand_up:
					is_crouching_in_another_bush = true
		
		if not is_crouching_in_another_bush:
			body.is_hidden = false
			body.can_stand_up = true
