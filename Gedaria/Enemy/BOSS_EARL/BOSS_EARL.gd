class_name BOSS_EARL, "res://Enemy/BOSS_EARL/BOSS_Earl.png"
extends Enemy


const FOOT_TRAP_PATH = preload("res://Enemy/BOSS_EARL/FootTrap.tscn")
const PATROLLER_PATH = preload("res://Enemy/E-Test/Patroller.tscn")
const GUARDIAN_PATH = preload("res://Enemy/E-Test/Guardian.tscn")

const KICK_SFX = preload("res://sfx/kick.wav")

var max_health = 0
var vlad_damage = 2
var health_limit = 0

var tossable_player = null
var throw_timer = null

var is_player_in_air = false
var has_jumped = true
var is_cutscene_finished = false
var can_throw_foot_traps = false


func _ready():
	hit_sfx = ["res://sfx/earl_hit1.wav", "res://sfx/earl_hit2.wav"]
	self.set_variable_health(get_parent().find_node("Vladimir").damage)
	throw_timer = get_tree().create_timer(0.0)
	
	$CanvasLayer/BossHPBar/Label.text = Languages.languages[Global.prefered_language]["boss3"]
# ------------------------------------------------------------------------------

func _process(delta):
	if not is_dead:
		$CanvasLayer/BossHPBar.calc_health(self.health, self.max_health)
		
		if is_done_once:
			if (health <= health_limit and health > health_limit-(2*vlad_damage)):
				is_done_once = false
				health_limit -= (max_health*0.3)
				self.jump()
				self.summon_enemies()
				return
			
		if is_player_in_air and tossable_player:
			if tossable_player.is_on_floor():
				tossable_player.is_moving = true
				tossable_player = null
				is_player_in_air = false
		
		velocity = move_and_slide(velocity)
		
	if throw_timer.time_left <= 0.0 and is_cutscene_finished and not is_dead:
		throw_timer = get_tree().create_timer(3.75)
		yield(throw_timer, "timeout")
		self.throw_foot_trap()
	
	if is_dead:
		$CanvasLayer/BossHPBar.hide()
# ------------------------------------------------------------------------------

func set_variable_health(vladimir_damage):
	self.vlad_damage = vladimir_damage
	self.health = 100 + (5*vladimir_damage)
	self.max_health = self.health
	self.health_limit = (max_health)-(max_health*0.3)
# ------------------------------------------------------------------------------		


func move(): # HANDLE MOVEMENT
	if not is_dead:
		# MOVE FROM 'A' TO 'B'
		if not has_player:
			
			if position.x > to:
				direction = -1
				$Sprite.flip_h = true
				$HitRay.cast_to.x = -FoV
				
			elif position.x < from:
				direction = 1
				$Sprite.flip_h = false
				$HitRay.cast_to.x = FoV
		
		velocity.x = speed * direction * int(is_moving) * int(not has_jumped) * int(is_cutscene_finished)
# ------------------------------------------------------------------------------
func jump():
	var TARGET_POSITION = Vector2(1955, 1060)
	$Tween.interpolate_property(self, "position", self.position, TARGET_POSITION, 0.5, Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
	yield(get_tree().create_timer(0.4), "timeout")
	has_jumped = true
# ------------------------------------------------------------------------------

func summon_enemies():
	var root = self.get_parent()
	for index in range(6):
		var enemy_path = GUARDIAN_PATH if randi()%2 == 0 else PATROLLER_PATH
		var enemy = enemy_path.instance()
		enemy.position = root.spawning_positions[index].position
		enemy.from = 500
		enemy.to = 1900
		enemy.health = 3
		enemy.speed = 220 + 10*randi()%6
		enemy.damage = 2
		enemy.FoV = 750
		
		if enemy is Patroller:
			enemy.type = Patroller.Type.ERNEST if randi()%3 == 1 else Patroller.Type.ERWIN
		
		root.arr_enemy.append(enemy)
		root.find_node("Enemies").call_deferred("add_child", enemy)
	
	root.can_spawn_pile_of_leaves = true
# ------------------------------------------------------------------------------

func hit(dmg, sound=""):
	if hit_in_row < 3:
		.hit(dmg, hit_sfx[randi()%2])
		self.hit_in_row += 1
		
		yield(get_tree().create_timer(0.75), "timeout")
		self.state_machine.travel("RUN")
		if hit_in_row > 1:
			yield(get_tree().create_timer(1.75), "timeout")
			self.hit_in_row = 0
		
		if has_jumped:
			var pile_of_leaves = self.get_parent().find_node("PilesOfLeaves")
			if pile_of_leaves.get_child_count() > 0:
				pile_of_leaves = pile_of_leaves.get_child(0)
				pile_of_leaves.call_deferred("queue_free")
				has_jumped = false
				is_done_once = true
				self.health += vlad_damage
# ------------------------------------------------------------------------------

func throw_foot_trap():
	if not has_jumped and can_throw_foot_traps:
	# play aniamation
		$AnimationTree.set("parameters/ATTACK/blend_position", direction)
		state_machine.travel('ATTACK')
		$Trap.show()
		self.is_moving = false
		
		yield(get_tree().create_timer(0.5), "timeout")
		if not is_dead:
			self.is_moving = true
			var foot_trap = FOOT_TRAP_PATH.instance()
			Global.level_root().call_deferred("add_child", foot_trap)
			foot_trap.global_position = self.position - Vector2(130*direction, -116)
# ------------------------------------------------------------------------------

func kick(play_animation_only=false):
	# KICK PLAYER BACK SO BOSS CAN ATTACK
	if self.has_player:
		state_machine.travel('KICK')
		AudioManager.play_sfx(KICK_SFX, 1, 0.1)
		
		yield(get_tree().create_timer(0.2), "timeout")
		player.hit(0)
		
		if play_animation_only:
			return
		$Tween.interpolate_property(player, "position", player.position, Vector2(player.position.x-250, player.position.y), 0.3, Tween.TRANS_SINE, Tween.EASE_IN, 0.45)
		$Tween.start()
# ------------------------------------------------------------------------------

func _on_TossArea_body_entered(body):
	if body.get_collision_layer_bit(1) and not is_dead:
		$AnimationTree.set("parameters/ATTACK/blend_position", direction)
		state_machine.travel('ATTACK')
		self.is_moving = false
		
		tossable_player = body
		tossable_player.velocity = Vector2(1000*-direction, -2500)
		tossable_player.is_moving = false
		tossable_player.is_raking = false
		
		if not is_dead:
			yield(get_tree().create_timer(0.1), "timeout")
			is_player_in_air = true
			if is_instance_valid(tossable_player.wind):
				tossable_player.wind.call_deferred("queue_free")
			tossable_player.is_aiming = false
			tossable_player.is_blowing = false
			
		if not is_dead:
			yield(get_tree().create_timer(0.5), "timeout")
			self.is_moving = true
# ------------------------------------------------------------------------------

func _on_Tween_tween_all_completed():
	yield(get_tree().create_timer(0.5), "timeout")
	self.state_machine.travel('STANDING')
