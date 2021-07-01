class_name BOSS_IN_CAVE, "res://Enemy/BOSS_Warden/BOSS_Warden.png"
extends Enemy

signal health_changed

const LEAF_PATH = preload("res://Level/Leaf.tscn")
const FALLING_ROCK_PATH = preload("res://Level/CaveDuel/Stone.tscn")

var is_done_once = true
var is_in_air = false
var can_fly = false
var was_in_air = false
var is_lunging = false

var tween_finished = true

var jump_over_height = 1450
var crouch_under_height = 1300
var max_leaves = 5
var leaves_counter = 0
var max_health = 0

var unconsciousness_timer = null
var turn_around_timer = null
var lunge_timer = null


func _ready():
	connect("health_changed", get_parent(), "add_pile_of_leaves")
	FoV = 1000
	state_machine = $AnimationTree.get("parameters/playback")
	max_health = health
	
	turn_around_timer = get_tree().create_timer(0.0, false)
	cooldown_timer = get_tree().create_timer(0.0, false)
	unconsciousness_timer = get_tree().create_timer(0.0, false)
	lunge_timer = get_tree().create_timer(0.0, false)
# ------------------------------------------------------------------------------

func _process(delta):
	if !is_dead:
		if has_player and !is_lunging and distance <= 135:
			attack()
		
		if health <= (max_health-10) and !is_in_air:
			lunge()
		
		# (45HP - 40HP>
		if health >= (max_health-10) and health < (max_health-5) and is_done_once:
			is_done_once = false
			can_fly = true

		# (40HP - 25HP)
		if health < (max_health-10) and health > (max_health/2):
			if $fly_timer.time_left <= 0.0:
				$fly_timer.start()

			# (35HP - 25HP)
			if health > max_health-15:
				is_done_once = true

			# <35HP - 25HP)
			elif health <= max_health-15 and is_done_once:
				is_done_once = false
				can_fly = true
				is_blocking = true

		# <25HP - 20HP>
		if health <= (max_health/2) and health >= (max_health-30):
			$fly_timer.paused = true
			can_fly = false

			if $falling_timer.time_left <= 0.0:
				$falling_timer.start()
				is_done_once = true

		# (20HP - 0HP>
		if health < (max_health-30):
			$fly_timer.paused = false
			if $fly_timer.time_left <= 0.0:
				$fly_timer.start()

			if $falling_timer.time_left <= 0.0 and !was_in_air:
				$falling_timer.start()

			# <10HP - 0HP>
			elif health <= max_health-40 and is_done_once:
				is_done_once = false
				can_fly = true
				is_blocking = true

		if can_fly:
			if position.x > (from+to)/2:
				fly(from-10, jump_over_height)
			elif position.x < (from+to)/2:
				fly(to+10, crouch_under_height)

		if was_in_air:
			if $GroundRay.is_colliding():
				is_moving = false
				was_in_air = false
		
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
	if !is_dead and !is_lunging:
	# MOVE FROM 'A' TO 'B'
		if !has_player:
			
			if position.x > to:
				direction = -1
				$Sprite.flip_h = false
				$HitRay.cast_to.x = -FoV
				
			elif position.x < from:
				direction = 1
				$Sprite.flip_h = true
				$HitRay.cast_to.x = FoV
				
			# LOOK AROUND FOR PLAYER
			if !is_in_air and !can_fly:
				if turn_around_timer.time_left <= 0.0:
					turn_around_timer = get_tree().create_timer(2.0, false)
					if !is_yield_paused:
						yield(turn_around_timer, "timeout")
						turn_around()
				
	# FOLLOW PLAYER OR NOT
		if has_player:
			
			# MOVE TOWARDS PLAYER (RIGHT)
			if player.position.x <= position.x+FoV and player.position.x > position.x:
				direction = 1
				if !can_attack:
					$Sprite.flip_h = true
					$HitRay.cast_to.x = FoV
			
			# MOVE TOWARDS PLAYER (LEFT)
			elif player.position.x >= position.x-FoV and player.position.x < position.x:
				direction = -1
				if !can_attack:
					$Sprite.flip_h = false
					$HitRay.cast_to.x = -FoV
			
		velocity.x = speed * direction * int(is_moving)
# ------------------------------------------------------------------------------		

func attack(): # PRIMARY ATTACK - STAB
	is_moving = false
	if cooldown_timer.time_left <= 0.0:
		cooldown_timer = get_tree().create_timer(0.5, false)
		if !is_yield_paused:
			yield(cooldown_timer, "timeout")
			
			$AnimationTree.set("parameters/ATTACK/blend_position", direction)
			state_machine.travel('ATTACK')
			
			if has_player:
				if !player.is_dead:
					if player and has_player and can_attack:
						if !player.is_blocking:
							player.hit(damage)
							print("Vladimir's health: ", player.health)
						
					if attack_timer.time_left <= 0.0:
						attack_timer = get_tree().create_timer(1.2, false)
						yield(attack_timer, "timeout")
						if !has_player:
							is_moving = true
						
					if cooldown_timer.time_left <= 0.0:
						cooldown_timer = get_tree().create_timer(1.5, false)
						yield(cooldown_timer, "timeout")
						is_moving = true
# ------------------------------------------------------------------------------

func fly(x, y):
	emit_signal("health_changed")
	
	if !is_in_air and can_fly:
		if tween_finished:
			$fly_timer.stop()
			$HitRay.enabled = false
			$HitRay2.enabled = false
			tween_finished = false
			is_in_air = true
			is_blocking = true
			GRAVITY.y = 0
			
			$AnimationTree.set("parameters/FLY/blend_position", direction)
			state_machine.travel('FLY')
			
			$Tween2.interpolate_property(self, "position", position, Vector2(position.x, y), 0.5, Tween.TRANS_SINE, Tween.EASE_IN)
			$Tween2.start()
			
			var new_pos = Vector2(position.x, y)
			$Tween.interpolate_property(self, "position", new_pos, Vector2(x, y), 2.0, Tween.TRANS_SINE, Tween.EASE_IN, 0.51)
			$Tween.start()
# ------------------------------------------------------------------------------

func falling_rocks():
	if !is_dead:
		is_moving = false
		is_blocking = true
		for i in range(7):
			var rock = FALLING_ROCK_PATH.instance()
			get_parent().find_node("Rocks").call_deferred("add_child", rock)
			
			randomize()
			var x = rand_range(-575, 1575)
			
			rock.gravity_scale = rand_range(0.4, 0.8)
			rock.mass = rand_range(1, 10)
			rock.position = Vector2(x, 565)
			
		if unconsciousness_timer.time_left <= 0.0 and !was_in_air:
			unconsciousness_timer = get_tree().create_timer(2.0, false)
			if !is_yield_paused:
				yield(unconsciousness_timer, "timeout")
				is_blocking = false
				is_moving = true
# ------------------------------------------------------------------------------

func hit(dmg):
	is_moving = false
	
	if is_blocking:
		state_machine.travel('HIT_UNBLOCKABLE')
	
	if !is_blocking:
		is_moving = true
		.hit(dmg)
		self.dodge()
# ------------------------------------------------------------------------------

func _on_Tween_tween_completed(object, key):
	is_moving = false
	
	var tween_timer = get_tree().create_timer(0.0, false)
	if tween_timer.time_left <= 0.0 and !was_in_air:
		tween_timer = get_tree().create_timer(2.5, false)
		if !is_yield_paused:
			yield(tween_timer, "timeout")
			print("Tween timeout")
			is_moving = true
			is_in_air = false
			tween_finished = true
			
			leaves_counter = get_parent().get_node("Leaves").get_child_count()
			spawn_leaves_in_range(leaves_counter)
# ------------------------------------------------------------------------------

func spawn_leaves_in_range(number):
	for n in range(max_leaves - number):
		var leaf = LEAF_PATH.instance()
		leaf.texture = "res://UI/list_lipa.png"
		get_parent().get_node("Leaves").add_child(leaf)
		leaf.position = self.position
# ------------------------------------------------------------------------------

func on_crashed_in_pile():
	print("C R A S H E D")
	$fly_timer.paused = true
	$Tween.stop_all()
	$LungeArea/CollisionShape2D.set_deferred("disabled", true)
	print("Tween has been stopped")
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
		if !is_yield_paused:
			yield(unconsciousness_timer, "timeout")
			print("unconsciousness timeout")
			$HitRay.enabled = true
			$HitRay2.enabled = true
			was_in_air = false
			is_moving = true
			$fly_timer.paused = false
			tween_finished = true
# ------------------------------------------------------------------------------

func turn_around(): # LOOK BACK AND FORTH
	if !is_dead and !has_player:
		state_machine.travel('STANDING')
		$Sprite.flip_h = !$Sprite.flip_h
		is_moving = false
		$HitRay.cast_to.x = -$HitRay.cast_to.x
		$HitRay2.cast_to.x = -$HitRay2.cast_to.x
		
		if turn_around_timer.time_left <= 0.0:
			turn_around_timer = get_tree().create_timer(0.75, false)
			if !is_yield_paused:
				yield(turn_around_timer, "timeout")
				is_moving = true
				
				if !has_player and !is_lunging:
					$Sprite.flip_h = !$Sprite.flip_h
					$HitRay.cast_to.x = -$HitRay.cast_to.x
					$HitRay2.cast_to.x = -$HitRay2.cast_to.x
				state_machine.travel('RUN')
# ------------------------------------------------------------------------------

func dodge():
	if !is_lunging:
		cooldown_timer.time_left = 1.5
		var x = position.x - 200*direction
		$Tween3.interpolate_property(self, "position", position, Vector2(x, position.y), 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
		$Tween3.start()
# ------------------------------------------------------------------------------

func lunge():
	if lunge_timer.time_left <= 0.0:
		if position.x >= -500 and position.x <= 1500:
			lunge_timer = get_tree().create_timer(4.5, false)
			if !is_yield_paused:
				yield(lunge_timer, "timeout")
				$AnimationTree.set("parameters/LUNGE/blend_position", direction)
				state_machine.travel('LUNGE')
				
				is_lunging = true
				$HitRay.enabled = false
				$HitRay2.enabled = false
				$AdvancedTween.play(2.33, 0, 5.5)
# ------------------------------------------------------------------------------

func _on_fly_timer_timeout():
	can_fly = true
	print("FLY")
# ------------------------------------------------------------------------------

func _on_falling_timer_timeout():
	falling_rocks()
# ------------------------------------------------------------------------------

func _on_AdvancedTween_advance_tween(sat):
	if !is_in_air:
		self.position.x += sat * -direction
# ------------------------------------------------------------------------------

func _on_AdvancedTween_tween_completed(object, key):
	$HitRay.enabled = true
	$HitRay2.enabled = true
	is_lunging = false
# ------------------------------------------------------------------------------

func _on_LungeArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		player = body
		
		if !player.is_dead and player:
			if !player.is_blocking:
				player.hit(damage)
				print("Vladimir's health: ", player.health)
