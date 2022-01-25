class_name BOSS_ONIHRO, "res://Enemy/BOSS_ONIHRO/BOSS_Onihro.png"
extends Enemy


const EXPLOSIVE_LEAF_HOLDERS_PATH = preload("res://Level/Fortress/ExplosiveLeafHolder.tscn")
const QUICKLEAVES_PATH = preload("res://Level/QuickLeaves.tscn")
const WIND_PATH = preload("res://Vladimir/WindBlowerWind.tscn")
const PILE_OF_LEAVES_PATH = preload("res://Enemy/BOSS_ONIHRO/OnihroPileOfLeaves.tscn")

const BLOWING_POSITION = Vector2(2650, 880)
const STARTING_POSITION = Vector2(3220, 850)

var smash_counter = 0
var combo_counter = -1
var max_health = 0
var explosives_y_level = 1646
var vlad_damage = 2
var health_limit = 0
var difficulty_time = 0
var blowing_time = 0.0

var can = false
var has_spawned_quickleaves = false
var is_hitted_by_wind = false
var can_be_hitted_again = false
var is_blowing = false
var enabler = true

var wind = null

var player_position = Vector2.ZERO


func _ready():
	self.set_variable_health(get_parent().find_node("Vladimir").damage)
	self.GRAVITY = Vector2.ZERO
	yield(get_tree().create_timer(0.5), "timeout")
	combo_counter = 0
	
	$CanvasLayer/BossHPBar/Label.text = Languages.languages[Global.prefered_language]["boss4"]
# ------------------------------------------------------------------------------

func _process(delta):
	if not is_dead:
		$CanvasLayer/BossHPBar.calc_health(self.health, self.max_health)
		
		if is_done_once:
			if (health <= health_limit and health > health_limit-(2*vlad_damage)):
				is_done_once = false
				health_limit -= (max_health*0.2)
				self.spawn_quickleaves()
				self.blow_wind()
				return
		
		# start left-right, both punch
		if combo_counter == 0 and can:
			self.combo()
		
		if is_hitted_by_wind:
			self.on_hitted_by_wind()
			
		player_position = self.get_parent().find_node("Vladimir").position
		
		if is_blowing and wind:
			wind.rotation_degrees = rad2deg(player_position.angle_to_point(wind.position))
# ------------------------------------------------------------------------------

func set_variable_health(vladimir_damage):
	self.vlad_damage = vladimir_damage
	var a = (5*vladimir_damage)
	self.health = 500 + a
	self.max_health = self.health
	self.health_limit = (max_health-a)-(max_health*0.25)
	difficulty_time = -0.325 + vladimir_damage*0.065
	$HandLeft.difficulty_time = difficulty_time
	$HandRight.difficulty_time = difficulty_time
# ------------------------------------------------------------------------------		

func on_hitted_by_wind():
	blowing_time = 0.0
	can_be_hitted_again = false
	is_hitted_by_wind = false
	self.is_blowing = false
	
	if state_machine.get_current_node() != "HIT":
		state_machine.travel("HIT")
	
	yield(get_tree().create_timer(2.0), "timeout")
	$Tween.interpolate_property(self, "position", self.position, STARTING_POSITION,\
								1.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
	yield(get_tree().create_timer(1.7), "timeout")
	self.disable_hands()
	combo_counter = 0
	has_spawned_quickleaves = false
	can = true
# ------------------------------------------------------------------------------

func hit(dmg, sound="res://sfx/onihro_hit.wav"):
	if is_hitted and not is_blocking:
		is_done_once = true
		.hit(dmg, sound)
# ------------------------------------------------------------------------------

func die():
	$Tween.interpolate_property(self, "position", self.position, Vector2(self.position.x, 1340),\
								1.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
	.die()
	
	yield(get_tree().create_timer(2.0), "timeout")
	$Sprite.hide()
	var pile_of_leaves = PILE_OF_LEAVES_PATH.instance()
	self.call_deferred("add_child", pile_of_leaves)

func smash():
	if not is_dead and not has_spawned_quickleaves:
		smash_counter = 0
		$HandRight.is_smashing_at_edges = false
		$HandLeft.is_smashing_at_edges = false
		$HandLeft.smash(player_position, Vector2(2720, 850))
# ------------------------------------------------------------------------------

func on_smash_end(side):
	if not is_dead and not has_spawned_quickleaves:
		if side == "Left" and smash_counter == 0:
			smash_counter += 1
			$HandRight.smash(player_position, Vector2(3720, 850))
			if $HandLeft.is_destroying_leaf_holders:
				self.get_parent().find_node("Camera2D").position.y = 1100
			
		if side == "Right" and smash_counter == 1:
			smash_counter = 2
			$HandRight.smash(player_position, Vector2(3720, 850), true)
			$HandLeft.smash(player_position, Vector2(2720, 850), true)
		
		if smash_counter == 2:
			yield(get_tree().create_timer(1.5-difficulty_time), "timeout")
			self.clap_hands()
			
			yield(get_tree().create_timer(3.0), "timeout")
			self.combo()
			
			if $HandLeft.is_destroying_leaf_holders:
				self.get_parent().destroy_all_leafholders()
# ------------------------------------------------------------------------------

func clap_hands():
	if not is_dead and not has_spawned_quickleaves:
		self.is_blocking = true
		$HandRight.clap($HandLeft.global_position)
		$HandLeft.clap($HandRight.global_position)
# ------------------------------------------------------------------------------

func smash_at_level_edges():
	if not is_dead and not has_spawned_quickleaves:
		smash_counter = 0
		$HandRight.is_smashing_at_edges = true
		$HandRight.smash(Vector2(4000, 1600), Vector2(3720, 850), true)
		
		$HandLeft.is_smashing_at_edges = true
		$HandLeft.smash(Vector2(2360, 1600), Vector2(2720, 850), true)
# ------------------------------------------------------------------------------

func on_hand_is_at_edge():
	if not is_dead and not has_spawned_quickleaves:
		var hand = $HandLeft if (smash_counter)%2 == 0 else $HandRight
		var other_hand = $HandRight if (smash_counter)%2 == 0 else $HandLeft
		
		if smash_counter < 4 and not other_hand.is_going_up:
			var landing_pos = Vector2(hand.global_position.x, 1300)
			hand.smash(landing_pos, hand.global_position)
			smash_counter += 1
			
			yield(get_tree().create_timer(1.5), "timeout")
			self.spawn_explosives_at(hand.global_position)
# ------------------------------------------------------------------------------

func spawn_explosives_at(spawn_pos):
	if not is_dead:
		randomize()
		var explosive_leaf_holder = EXPLOSIVE_LEAF_HOLDERS_PATH.instance()
		explosive_leaf_holder.initial_position = spawn_pos
		self.get_parent().call_deferred("add_child", explosive_leaf_holder)
		
		yield(get_tree().create_timer(0.1), "timeout")
		if is_instance_valid(explosive_leaf_holder):
			var tween = explosive_leaf_holder.find_node("Tween")
			tween.interpolate_property(explosive_leaf_holder, "initial_position",\
									 explosive_leaf_holder.initial_position,\
									Vector2(2800+(randi()%11*115), explosives_y_level),\
									 1.25, Tween.TRANS_BACK, Tween.EASE_IN)
			tween.start()
# ------------------------------------------------------------------------------

func combo():
	if not is_dead:
		if combo_counter < 2:
			self.smash()
		elif combo_counter == 2:
			$HandLeft.transition()
			$HandRight.transition()
			yield(get_tree().create_timer(1.0), "timeout")
			self.smash_at_level_edges()
			
			yield(get_tree().create_timer(8.5), "timeout")
			$HandLeft.transition(true)
			$HandRight.transition(true)
			
			yield(get_tree().create_timer(2.0), "timeout")
			combo_counter = -1
	
		combo_counter += 1
# ------------------------------------------------------------------------------

func spawn_quickleaves():
	if not is_dead:
		state_machine.travel("LAUGHTER")
		
		var quick_leaves = QUICKLEAVES_PATH.instance()
		self.get_parent().call_deferred("add_child", quick_leaves)
		quick_leaves.number_of_levels = 4
		quick_leaves.z_index = -22
		quick_leaves.leaf_holder_per_level = 14
		quick_leaves.scale = Vector2(1.5, 1.5)
		quick_leaves.position = Vector2(2158, 1840)
		
		var collision = quick_leaves.find_node("CollisionShape2D")
		collision.shape.extents = Vector2(530, 100)
		collision.position = Vector2(500, 200)
		
		has_spawned_quickleaves = true
		
		$Tween.interpolate_property(quick_leaves, "position", quick_leaves.position,\
								Vector2(2158, 1160), 1.5, Tween.TRANS_BACK, Tween.EASE_IN)
		$Tween.start()
# ------------------------------------------------------------------------------

func blow_wind():
	self.disable_hands()
	state_machine.travel("FLY")
	$Tween.interpolate_property(self, "position", self.position, BLOWING_POSITION,\
								1.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
	yield(get_tree().create_timer(1.6), "timeout")
	
	wind = WIND_PATH.instance()
	wind.can_blow_player = true
	wind.impulse = Vector2(0.5, 0.8)
	wind.position = self.position + Vector2(300, 0)
	self.get_parent().call_deferred("add_child", wind)
	self.is_blowing = true
	
	$HandLeft.transition(true)
	$HandRight.transition(true)
# ------------------------------------------------------------------------------

func disable_hands():
	$HandLeft/SuperArea2D/CollisionShape2D.set_deferred("disabled", enabler)
	$HandLeft/CollisionShape2D.set_deferred("disabled", enabler)
	$HandRight/SuperArea2D/CollisionShape2D.set_deferred("disabled", enabler)
	$HandRight/CollisionShape2D.set_deferred("disabled", enabler)
	enabler = not enabler
