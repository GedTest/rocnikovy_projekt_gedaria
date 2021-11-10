class_name BOSS_EARL, "res://Enemy/BOSS_EARL/BOSS_Earl.png"
extends Enemy


const FOOT_TRAP_PATH = preload("res://Enemy/BOSS_EARL/FootTrap.tscn")
const PATROLLER_PATH = preload("res://Enemy/E-Test/Patroller.tscn")
const GUARDIAN_PATH = preload("res://Enemy/E-Test/Guardian.tscn")

const KICK_SFX = preload("res://sfx/kick.wav")

var tossable_player = null

var is_player_in_air = false
var has_jumped = false


func _process(delta):
	if not is_dead:
		if Input.is_action_just_pressed("block"):
			kick()
#			self.jump()
#			self.summon_enemies()
#			self.throw_foot_trap()
			
		if is_player_in_air and tossable_player:
			if tossable_player.is_on_floor():
				tossable_player.is_moving = true
				tossable_player = null
				is_player_in_air = false
		
		velocity = move_and_slide(velocity)
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
		

		velocity.x = speed * direction * int(is_moving) * int(not has_jumped)
# ------------------------------------------------------------------------------

func jump():
	has_jumped = true
	var TARGET_POSITION = Vector2(2105, 1060)
	$Tween.interpolate_property(self, "position", self.position, TARGET_POSITION, 0.5, Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
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
		root.call_deferred("add_child", enemy)
	
	root.can_spawn_pile_of_leaves = true
# ------------------------------------------------------------------------------

func hit(dmg):
	.hit(dmg)
	
	if has_jumped:
		var pile_of_leaves = self.get_parent().find_node("PilesOfLeaves").get_child(0)
		pile_of_leaves.call_deferred("queue_free")
		has_jumped = false
# ------------------------------------------------------------------------------

func throw_foot_trap():
	# play aniamation
	$AnimationTree.set("parameters/ATTACK/blend_position", direction)
	state_machine.travel('ATTACK')
	$Trap.show()
	self.is_moving = false
	
	if not is_dead:
		yield(get_tree().create_timer(0.5), "timeout")
		self.is_moving = true
		var foot_trap = FOOT_TRAP_PATH.instance()
		Global.level_root().call_deferred("add_child", foot_trap)
		foot_trap.global_position = self.position - Vector2(130*direction, -116)
# ------------------------------------------------------------------------------

func kick():
	# KICK PLAYER BACK SO BOSS CAN ATTACK
	if self.has_player:
		state_machine.travel('KICK')
		AudioManager.play_sfx(KICK_SFX, 0, 0.35)
		
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
		
		if not is_dead:
			yield(get_tree().create_timer(0.1), "timeout")
			is_player_in_air = true
		if not is_dead:
			yield(get_tree().create_timer(0.5), "timeout")
			self.is_moving = true
# ------------------------------------------------------------------------------

func _on_Tween_tween_all_completed():
	state_machine.travel('STANDING')
