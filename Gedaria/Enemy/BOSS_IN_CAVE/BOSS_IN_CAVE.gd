class_name BOSS_IN_CAVE, "res://Enemy/BOSS_Warden/BOSS_Warden.png"
extends Enemy
"""
Boss Rudolph
is derived from base enemy class,
he wants to abuse vlad and steal his legendary rake
"""



signal health_changed

const LEAF_PATH = preload("res://Level/Leaf.tscn")
const FALLING_ROCK_PATH = preload("res://Level/CaveDuel/Stone.tscn")
const BAT_PATH = preload("res://Level/CaveEntrance/Bat.tscn")
const STALACTITE_PATH = preload("res://Level/CaveEntrance/Stalactite.tscn")

var is_done_once = true
var can_emit_signal = true
var is_in_air = false
var is_vlad_in_quickleaves = false
var can_fly = false
var was_in_air = false
var is_lunging = false
var can_lunge = true
var can_spawn_stalactites = true
var is_in_minecart = false
var tween_finished = true
var is_first_phase = true

var jump_over_height = 1450
var crouch_under_height = 1300
var max_leaves = 5
var leaves_counter = 0
var max_health = 0
var previous_number = 5

var unconsciousness_timer = null
var lunge_timer = null
var summoning_timer = null
var despawn_timer = null


func _ready():
	FoV = 1000
	state_machine = $AnimationTree.get("parameters/playback")
	
	turn_around_timer = get_tree().create_timer(0.0, false)
	cooldown_timer = get_tree().create_timer(0.0, false)
	unconsciousness_timer = get_tree().create_timer(0.0, false)
	lunge_timer = get_tree().create_timer(0.0, false)
	summoning_timer = get_tree().create_timer(0.0, false)
	despawn_timer = get_tree().create_timer(0.0, false)
# ------------------------------------------------------------------------------

func _process(delta):
	if not is_dead:
		$CanvasLayer/BossHPBar/Label.text = 'BOSS_IN_CAVE: ' + str(self.health) 
		$CanvasLayer/BossHPBar/Health.rect_size.x = 5 * self.health
		if player and has_player and not is_lunging:
			if distance <= 135:
				.attack(1.2, 0.6)
		
		# Player has min 6 damage:
		# (138HP)
		if health <= (max_health-12) and not is_in_air:
			self.lunge()
		
		if is_first_phase:
			# (176HP - 150HP)
			if health >= (max_health*0.75) and health < (max_health*0.9) and is_done_once:
				is_done_once = false
				can_fly = true
	
			# (182HP - 112HP)
			if health <= (max_health*0.91) and health > (max_health*0.56):
				if $event_timer.time_left <= 0.0:
					$event_timer.start()
	
				# (136HP - 130HP)
				if health > (max_health*0.65) and health <= (max_health*0.68):
					is_done_once = true
	
				# (124HP)
				elif health <= (max_health*0.62) and is_done_once:
					is_done_once = false
					can_fly = true
					is_blocking = true

			# (120HP - 110HP)
			if health <= (max_health*0.6) and health >= (max_health*0.55):
				if not is_in_minecart and Global.level_root().filename == "res://Level/CaveDuel/Cave duel.tscn":
					is_in_minecart = true
					is_first_phase = false
					self.disconnect("health_changed", get_parent(), "add_pile_of_leaves")
					can_emit_signal = false
					is_done_once = false
					Global.level_root().collapse_floor()
					can_fly = false
			
			if can_fly and is_first_phase and not is_in_minecart:
				if position.x > (from+to)/2:
					self.fly(from-10, jump_over_height)
				elif position.x < (from+to)/2:
					self.fly(to+10, crouch_under_height)
	
			if was_in_air:
				if $GroundRay.is_colliding():
					is_moving = false
					was_in_air = false
	
		# S E C O N D    P H A S E
		# (100HP - 0HP)
		if not is_first_phase and not is_in_minecart:
			# (88HP - 0HP)
			if health < (max_health*0.46):
				if not is_done_once:
					$event_timer.wait_time = 5.5
					self.falling_rocks()
					$falling_timer.start()
					is_done_once = true
					
				if summoning_timer.time_left <= 0.0:
					summoning_timer = get_tree().create_timer(6.5, false)
					if not is_yield_paused:
						yield(summoning_timer, "timeout")
						self.summon_bats()
			
			# (82HP - 0HP)
			if health < (max_health*0.39):
				if $event_timer.time_left <= 0.0 and can_spawn_stalactites:
					can_spawn_stalactites = false
					$event_timer.start()
			
						
		# does he see the player ?
		if $HitRay.is_colliding() and $HitRay.get_collider().name == "Vladimir" or $HitRay2.is_colliding() and $HitRay2.get_collider().name == "Vladimir":
			player = $HitRay.get_collider() if $HitRay.get_collider() != null else $HitRay2.get_collider()
			has_player = true
		else:
			player = null
			has_player = false
		
		velocity = move_and_slide(velocity)
# ------------------------------------------------------------------------------

func move(): # HANDLE MOVEMENT
	if not is_dead and not is_lunging:
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
			if not is_in_air and not can_fly:
				if turn_around_timer.time_left <= 0.0:
					turn_around_timer = get_tree().create_timer(2.0, false)
					if not is_yield_paused:
						yield(turn_around_timer, "timeout")
						self.turn_around()
				
	# FOLLOW PLAYER OR NOT
		if has_player:
			
			# MOVE TOWARDS PLAYER (RIGHT)
			if player.position.x <= position.x+FoV and player.position.x > position.x:
				direction = 1
				if not can_attack:
					$Sprite.flip_h = true
					$HitRay.cast_to.x = FoV
			
			# MOVE TOWARDS PLAYER (LEFT)
			elif player.position.x >= position.x-FoV and player.position.x < position.x:
				direction = -1
				if not can_attack:
					$Sprite.flip_h = false
					$HitRay.cast_to.x = -FoV
			
		velocity.x = speed * direction * int(is_moving)
# ------------------------------------------------------------------------------		

func set_variable_health(vladimir_damage):
	self.health = 200 + int(100/vladimir_damage)
	self.max_health = self.health
	
	if self.health >= 100:
		self.connect("health_changed", get_parent(), "add_pile_of_leaves")
	else:
		self.disconnect("health_changed", get_parent(), "add_pile_of_leaves")
# ------------------------------------------------------------------------------		

#func attack(): # PRIMARY ATTACK - STAB
#	is_moving = false
#	if cooldown_timer.time_left <= 0.0:
#		cooldown_timer = get_tree().create_timer(0.5, false)
#		if not is_yield_paused:
#			yield(cooldown_timer, "timeout")
#
#			$AnimationTree.set("parameters/ATTACK/blend_position", direction)
#			state_machine.travel('ATTACK')
#
#			if has_player:
#				if not player.is_dead:
#					if player and has_player and can_attack:
#						if not player.is_blocking:
#							player.hit(damage)
#
#					if attack_timer.time_left <= 0.0:
#						attack_timer = get_tree().create_timer(1.2, false)
#						yield(attack_timer, "timeout")
#						if not has_player:
#							is_moving = true
#
#					if cooldown_timer.time_left <= 0.0:
#						cooldown_timer = get_tree().create_timer(1.5, false)
#						yield(cooldown_timer, "timeout")
#						is_moving = true
# ------------------------------------------------------------------------------

func fly(x, y):
	if is_first_phase and can_emit_signal:
		self.emit_signal("health_changed")
	
	if not is_in_air and can_fly:
		if tween_finished:
			$event_timer.stop()
			$HitRay.enabled = false
			$HitRay2.enabled = false
			can_fly = false
			tween_finished = false
			is_in_air = true
			is_blocking = true
			GRAVITY.y = 0
			
			$AnimationTree.set("parameters/FLY/blend_position", direction)
			state_machine.travel('FLY')
			
			$Tween2.interpolate_property(self, "position", position, Vector2(position.x, y), 0.5, Tween.TRANS_SINE, Tween.EASE_IN)
			$Tween2.start()
			
			var new_pos = Vector2(position.x, y)
			$Tween.interpolate_property(self, "position", new_pos, Vector2(x, y), 2.0, Tween.TRANS_SINE, Tween.EASE_IN, 0.55)
			$Tween.start()
# ------------------------------------------------------------------------------

func _on_falling_timer_timeout():
	$falling_timer.start()
	self.falling_rocks()
# ------------------------------------------------------------------------------

func falling_rocks():
	if not is_dead and not is_vlad_in_quickleaves:
		is_moving = false
		for i in range(7):
			var rock = FALLING_ROCK_PATH.instance()
			
			randomize()
			var x = rand_range(24850, 27600)
			var y_offset = rand_range(0, 100)
			
			Global.level_root().call_deferred("add_child", rock)
			rock.gravity_scale = rand_range(0.4, 0.8)
			rock.mass = rand_range(1, 10)
			rock.position = Vector2(x, 4500-y_offset)
			
		if unconsciousness_timer.time_left <= 0.0:
			unconsciousness_timer = get_tree().create_timer(2.0, false)
			if not is_yield_paused:
				yield(unconsciousness_timer, "timeout")
				is_moving = true
# ------------------------------------------------------------------------------

func hit(dmg):
	is_moving = false
	
	if is_blocking:
		state_machine.travel('HIT_UNBLOCKABLE')
	
	if not is_blocking:
		is_moving = true
		if not is_first_phase and not is_in_minecart:
			hit_in_row += 1
			
			if hit_in_row > 2:
				hit_in_row = 0
				self.quickleaves()
		
		.hit(dmg)
		if not is_in_minecart:
			self.dodge()
# ------------------------------------------------------------------------------

func _on_Tween_tween_completed(object, key):
	is_moving = false
	
	var tween_timer = get_tree().create_timer(0.0, false)
	if tween_timer.time_left <= 0.0 and not was_in_air:
		tween_timer = get_tree().create_timer(2.5, false)
		if not is_yield_paused:
			yield(tween_timer, "timeout")
			is_moving = true
			is_in_air = false
			tween_finished = true
			
			leaves_counter = get_parent().get_node("Leaves").get_child_count()
			self.spawn_leaves_in_range(leaves_counter)
# ------------------------------------------------------------------------------

func spawn_leaves_in_range(number):
	for n in range(max_leaves - number):
		var leaf = LEAF_PATH.instance()
		leaf.texture = "res://UI/list_lipa.png"
		self.get_parent().get_node("Leaves").add_child(leaf)
		leaf.position = self.position
# ------------------------------------------------------------------------------

func on_crashed_in_pile():
	$event_timer.paused = true
	$Tween.stop_all()
	$LungeArea/CollisionShape2D.set_deferred("disabled", true)
	$HitRay.enabled = false
	$HitRay2.enabled = false
	can_fly = false
	is_in_air = false
	GRAVITY.y = 98
		
	was_in_air = true
	is_moving = false
	is_blocking = false
	
	if unconsciousness_timer.time_left <= 0.0:
		unconsciousness_timer = get_tree().create_timer(4.75, false)
		if not is_yield_paused:
			yield(unconsciousness_timer, "timeout")
			$HitRay.enabled = true
			$HitRay2.enabled = true
			was_in_air = false
			is_moving = true
			$event_timer.paused = false
			tween_finished = true
# ------------------------------------------------------------------------------

func turn_around(): # LOOK BACK AND FORTH
	if not is_dead and not has_player:
		state_machine.travel('STANDING')
		$Sprite.flip_h = not $Sprite.flip_h
		is_moving = false
		$HitRay.cast_to.x = -$HitRay.cast_to.x
		$HitRay2.cast_to.x = -$HitRay2.cast_to.x
		$WallDetection.position.x *= -1
		
		if turn_around_timer.time_left <= 0.0:
			turn_around_timer = get_tree().create_timer(0.75, false)
			if not is_yield_paused:
				yield(turn_around_timer, "timeout")
				is_moving = true
				
				if not has_player and not is_lunging:
					$Sprite.flip_h = not $Sprite.flip_h
					$HitRay.cast_to.x = -$HitRay.cast_to.x
					$HitRay2.cast_to.x = -$HitRay2.cast_to.x
					$WallDetection.position.x *= -1
				state_machine.travel('RUN')
# ------------------------------------------------------------------------------

func dodge():
	if position.x > from +200 and position.x < to -200:
		if not is_lunging:
			cooldown_timer.time_left = 1.5
			var x = position.x - 200*direction
			$Tween3.interpolate_property(self, "position", position, Vector2(x, position.y), 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
			$Tween3.start()
# ------------------------------------------------------------------------------

func lunge():
	if can_lunge and position.x >= -500 and position.x <= 1500:
		$AnimationTree.set("parameters/LUNGE/blend_position", direction)
		state_machine.travel('LUNGE')
		
		is_lunging = true
		can_lunge = false
		$HitRay.enabled = false
		$HitRay2.enabled = false
		$AdvancedTween.play(2.33, 0, 5.5)
# ------------------------------------------------------------------------------

func _on_event_timer_timeout():
	if is_first_phase:
		can_fly = true
	
	elif not is_in_minecart:
		is_moving = false
		self.stalactite_wave()
# ------------------------------------------------------------------------------

func _on_AdvancedTween_advance_tween(sat):
	if not is_in_air:
		self.position.x += sat * -direction
# ------------------------------------------------------------------------------

func _on_AdvancedTween_tween_completed(object, key):
	$HitRay.enabled = true
	$HitRay2.enabled = true
	is_lunging = false
	
	# cooldown before next lunge
	if lunge_timer.time_left <= 0.0:
		lunge_timer = get_tree().create_timer(2.5, false)
		if not is_yield_paused:
			yield(lunge_timer, "timeout")
			can_lunge = true
# ------------------------------------------------------------------------------

func _on_LungeArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		player = body
		
		if not player.is_dead and player:
			if not player.is_blocking:
				player.hit(damage)
# ------------------------------------------------------------------------------

func summon_bats():
	var BAT_COUNT = 11
	var level = self.get_parent()
	var number = randi() % 6
	var index = 0
	
	if BAT_COUNT+previous_number-3 > level.arr_bats.size():
		previous_number = number
		for i in range(number):
			index = randi() % 6
			var bat = BAT_PATH.instance()
			bat.position = level.spawning_positions[index].position
			bat.from = 25000
			bat.to = 27500
			bat.health = 3
			bat.speed = 250
			bat.damage = 2
			bat.FoV = 750
			if index == 0 or index == 3 or index == 6:
				bat.height = 4850
			else:
				bat.height = 4675
			
			level.call_deferred("add_child", bat)
			level.arr_bats.append(bat)
# ------------------------------------------------------------------------------

func stalactite_wave():
	if not is_vlad_in_quickleaves:
		var stalactites = []
		for i in range(8):
			var stalactite = STALACTITE_PATH.instance()
			stalactite.scale.y = 0.8-(i*0.05)
			stalactite.rotation_degrees = 180
			var offset = Vector2((100 + i*70)*direction, 200)
			stalactite.position = self.position + offset
			stalactite.frame = 3
			stalactite.z_index = -2
			$Tween4.interpolate_property(stalactite, "position", stalactite.position, Vector2(stalactite.position.x, stalactite.position.y-80), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, i*0.2)
			self.get_parent().call_deferred("add_child", stalactite)
			stalactites.append(stalactite)
			$Tween4.start()
			
			
		if despawn_timer.time_left <= 0.0:
			despawn_timer = get_tree().create_timer(1.5, false)
			if not is_yield_paused:
				yield(despawn_timer, "timeout")
				for stalactite in stalactites:
					stalactite.call_deferred("queue_free")
				can_spawn_stalactites = true
				is_moving = true
# ------------------------------------------------------------------------------

func quickleaves():
	if not is_vlad_in_quickleaves:
		is_vlad_in_quickleaves = true
		self.is_moving = false
		Global.level_root().set_quick_leaves()
# ------------------------------------------------------------------------------

func _on_quickleaves_completed():
	is_vlad_in_quickleaves = false
	self.is_moving = true
	Global.level_root().set_quick_leaves(true)
# ------------------------------------------------------------------------------

func set_values():
	# RESET VALUES AFTER COMING FROM PREVIOUS BOSS-ARENA
	var previous_level = "res://Level/CaveDuel/Cave duel.tscn"
	var boss_data = "["+previous_level+", BOSS_IN_CAVE]"
	var data = {}

	if SaveLoad.slots["slot_4"].has(boss_data):
		data = SaveLoad.slots["slot_4"][boss_data]
	
	for value in data:
		if value == "pos" or \
			value == "file" or \
			value == "parent" or \
			value == "to" or \
			value == "from":
			continue
		self.set(value, data[value])
# ------------------------------------------------------------------------------

func save():
	things_to_save.is_first_phase = self.is_first_phase
	things_to_save.is_done_once = self.is_done_once
	.save()
	return things_to_save
