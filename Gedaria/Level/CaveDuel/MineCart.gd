extends StaticBody2D


var has_enemy = false
var is_done_once = false
var is_yield_paused


func _ready():
	is_yield_paused = Global.is_yield_paused
# ------------------------------------------------------------------------------

func _process(delta):
	if get_parent().find_node("MineCart2").has_enemy and is_done_once:
		is_done_once = false
		yield(get_tree().create_timer(1.0), "timeout")
		self.get_parent().find_node("AnimationPlayer").play("MINECART_MOVES")
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	if body.get_collision_layer_bit(2):
		body.state_machine.travel("STANDING")
		self.has_enemy = true
	if body.get_collision_layer_bit(1):
		self.is_done_once = true
		get_parent().find_node("StaticBodySlider").find_node("CollisionShape2D").set_deferred("disabled", true)
