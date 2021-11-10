extends Sprite


const BROKEN_STAIRS_PATH = "res://Level/CultInCave/BrokenStairs.png"

export(bool) var is_broken = false


func _ready():
	if is_broken:
		self.texture = load(BROKEN_STAIRS_PATH)
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
