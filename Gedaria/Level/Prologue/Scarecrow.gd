extends Enemy


const SCARECROW_SFX = preload("res://sfx/scarecrow.wav")

var previous_hp = 0


func _ready():
	previous_hp = health
	speed = 0
# ------------------------------------------------------------------------------

func _process(delta):
	if is_instance_valid(self):
		if health <= 0:
			$AnimatedSprite.play("dead")
			$Sprite.texture = load("res://Level/Chase/seno.png")
			$CollisionShape2D.disabled = true
			emit_signal("tree_exiting")
			set_process(false)
			disconnect("tree_exiting",get_parent(), "_on_Scarecrow_tree_exiting")
			self.z_index = 0
			
		if health != previous_hp:
			AudioManager.play_sfx(SCARECROW_SFX, 0)
			$Particles2D.emitting = true
		previous_hp = health
# ------------------------------------------------------------------------------
