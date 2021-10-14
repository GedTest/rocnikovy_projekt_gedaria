class_name BOSS_EARL, "res://Enemy/BOSS_Warden/BOSS_Warden.png"
extends Enemy


const FOOT_TRAP_PATH = preload("res://Enemy/BOSS_EARL/FootTrap.tscn")
const PATROLLER_PATH = preload("res://Enemy/E-Test/Patroller.tscn")
const GUARDIAN_PATH = preload("res://Enemy/E-Test/Guardian.tscn")

var tossable_player = null

var is_player_in_air = false


func _ready():
	pass
# ------------------------------------------------------------------------------

func _process(delta):
	if not is_dead:
		if Input.is_action_just_pressed("crouch"):
			self.jump()
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
				$Sprite.flip_h = false
				$HitRay.cast_to.x = -FoV
				
			elif position.x < from:
				direction = 1
				$Sprite.flip_h = true
				$HitRay.cast_to.x = FoV
				
			# LOOK AROUND FOR PLAYER
			if turn_around_timer.time_left <= 0.0:
				turn_around_timer = get_tree().create_timer(2.0, false)
				if not is_yield_paused:
					yield(turn_around_timer, "timeout")
					self.turn_around()
		
		velocity.x = speed * direction * int(is_moving)
# ------------------------------------------------------------------------------

func turn_around(): # LOOK BACK AND FORTH
	if not is_dead and not has_player:
		state_machine.travel('STANDING')
		$Sprite.flip_h = not $Sprite.flip_h
		is_moving = false
		$HitRay.cast_to.x = -$HitRay.cast_to.x
		$HitRay2.cast_to.x = -$HitRay2.cast_to.x
		$WallDetection.position.x *= -1
		$TossArea.position.x *= -1
		
		if turn_around_timer.time_left <= 0.0:
			turn_around_timer = get_tree().create_timer(0.75, false)
			if not is_yield_paused:
				yield(turn_around_timer, "timeout")
				is_moving = true
				
				if not has_player:
					$Sprite.flip_h = not $Sprite.flip_h
					$HitRay.cast_to.x = -$HitRay.cast_to.x
					$HitRay2.cast_to.x = -$HitRay2.cast_to.x
					$WallDetection.position.x *= -1
					$TossArea.position.x *= -1
				state_machine.travel('RUN')
# ------------------------------------------------------------------------------

func jump():
	var TARGET_POSITION = Vector2(22380, 3680)
	$Tween.interpolate_property(self, "position", self.position, TARGET_POSITION, 0.5, Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
# ------------------------------------------------------------------------------

func summon_enemies():
	for i in range(5):
		var enemy_path = PATROLLER_PATH if randi()%2 == 0 else GUARDIAN_PATH
		var enemy = enemy_path.instance()
		enemy.position = self.get_parent().spawning_positions[i]
		enemy.from = 25000
		enemy.to = 27500
		enemy.health = 3
		enemy.speed = 250
		enemy.damage = 2
		enemy.FoV = 750
		
		self.get_parent().call_deferred("add_child", enemy)
# ------------------------------------------------------------------------------
func throw_foot_trap():
	# play aniamation
	var foot_trap = FOOT_TRAP_PATH.instance()
	Global.level_root().call_deferred("add_child", foot_trap)
	foot_trap.global_position = self.position - Vector2(120*direction, -50)
# ------------------------------------------------------------------------------

func _on_TossArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		tossable_player = body
		tossable_player.velocity = Vector2(1000*-direction, -2500)
		tossable_player.is_moving = false
		
		yield(get_tree().create_timer(0.1), "timeout")
		is_player_in_air = true

#func toss_vladimir(tossable_player):
#	var toss_direction = 1 if self.position.x - tossable_player.position.x > 0 else -1
#	var x = 350 * toss_direction
#	$Tween.interpolate_property(tossable_player, "position", tossable_player.position, Vector2(tossable_player.position.x+x, tossable_player.position.y), 0.3, Tween.TRANS_SINE, Tween.EASE_IN, 0.3)
#	$Tween.start()
# ------------------------------------------------------------------------------


func _on_TossArea_body_exited(body):
	if body.get_collision_layer_bit(1):
		pass
#		tossable_player = null
