class_name BOSS_ONIHRO, "res://Enemy/BOSS_Warden/BOSS_Warden.png"
extends Enemy


var smash_counter = 0

var player_x_position = Vector2.ZERO


func _ready():
	pass
# ------------------------------------------------------------------------------

func _process(delta):
	if not is_dead:
		# start left-right, both punch
		if Input.is_action_just_pressed("crouch"):
			self.smash()
# ------------------------------------------------------------------------------

func hit(dmg):
	.hit(dmg)
# ------------------------------------------------------------------------------

func smash():
	player_x_position = self.get_parent().find_node("Vladimir").position.x
	smash_counter = 0
	$HandLeft.smash(player_x_position)
# ------------------------------------------------------------------------------

func on_smash_end(side):
	if side == "Left" and smash_counter == 0:
		player_x_position = self.get_parent().find_node("Vladimir").position.x
		smash_counter += 1
		$HandRight.smash(player_x_position)
		
	if side == "Right" and smash_counter == 1:
		player_x_position = self.get_parent().find_node("Vladimir").position.x
		smash_counter = 2
		$HandRight.smash(player_x_position, true)
		$HandLeft.smash(player_x_position, true)
	
	if smash_counter == 2:
		yield(get_tree().create_timer(1.3), "timeout")
		self.clap_hands()
# ------------------------------------------------------------------------------

func clap_hands():
	$HandRight.clap($HandLeft.global_position)
	$HandLeft.clap($HandRight.global_position)

