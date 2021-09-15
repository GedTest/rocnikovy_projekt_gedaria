class_name Vladimir, "res://Vladimir/animations/Vladimir.png"
extends KinematicBody2D
"""
Main character
young serf who wants to be free, 
once he found the legendary rake he became a hero
"""



const GRAVITY = Vector2(0, 98)
const FLOOR_NORMAL = Vector2(0, -1)
const PEBBLE_PATH = preload("res://Vladimir/Pebble.tscn")
const WIND_PATH = preload("res://Vladimir/WindBlowerWind.tscn")

export(int) var speed = 480
export(int) var modify_speed = 1
export(int) var jump_strength = 1700
export(int) var damage = 2
export(int) var max_health = 12
export(int) var health = 12

var shoot_distance = 500
var acorn_counter = 0
var pebble_counter = 0
var heavy_attack_counter = 0
var heavy_attack_increment = 4
var next_pos_ID = ""

var direction = 1
var attack_direction = 1
var velocity = Vector2(0, 0)
var mouse_position = Vector2(0, 0)
var jumped_height = Vector2(0, 0)

var is_dead = false
var is_moving = true
var can_move = true
var can_jump = true
var can_stand_up = true
var is_crouching = false
var can_attack = false
var is_attacking = false
var is_blocking = false
var is_hidden = false
var is_aiming = false
var is_hitted = false
var is_raking = false
var is_blowing = false
var was_blowing = false
var is_yield_paused = false
var has_slingshot = false

var has_learned_attack = true
var has_learned_heavy_attack = true
var has_learned_raking = true
var has_learned_blocking = true
var has_learned_leaf_blower = true

var enemy = null
var wind = null

var block_timer = null
var breakable_stone = null
var attack_timer = null
var heavy_attack_timer = null
var jump_forgivness_timer = 0.0
var blowing_time = 0.0
var throw_timer = null
var state_machine = null


func _ready():
	self.set_collision_layer_bit(1, true)
	state_machine = $AnimationTree.get("parameters/playback")
	attack_timer = get_tree().create_timer(0.0)
	heavy_attack_timer = get_tree().create_timer(0.0)
	block_timer = get_tree().create_timer(0.0)
	throw_timer = get_tree().create_timer(0.0)
# ------------------------------------------------------------------------------	

# warning-ignore:unused_argument
func _physics_process(delta):
	if not is_dead:
		# GRAVITY
		velocity.y += GRAVITY.y
	
		is_yield_paused = self.get_parent().is_yield_paused
		self.update() # Draw function
		
		
	# IS HE ALIVE ?
		if health <= 0:
			self.die()
			
	# IF HE'S NOT STOP BY SOME EVENT
		if is_moving:
			self.jump(delta)
			self.move()
			self.crouch()
			self.attack()
			self.heavy_attack(delta)
			self.blowing(delta)
			self.shoot()
			self.block()
			self.rake()
		
	# I don't like this method, it already multiply by delta
	if is_dead:
		self.velocity = Vector2.ZERO
		
	velocity = move_and_slide(velocity, FLOOR_NORMAL, \
							  false, 4, PI,false)
# ------------------------------------------------------------------------------

func jump(delta): # JUMP
	var MAX_TIME = 0.1
	
	can_jump = true if ($GroundRay.is_colliding() or
						$GroundRay2.is_colliding() or
						$GroundRay3.is_colliding()
						)else false
	
	if can_jump:
		jump_forgivness_timer = 0.0
		jumped_height.y = position.y
	else:
		jump_forgivness_timer += delta
		if jump_forgivness_timer <= MAX_TIME:
			can_jump = true
						
	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = -jump_strength
# ------------------------------------------------------------------------------

func move(): # MOVE
	if Input.is_action_pressed("right") and (not is_raking or is_blowing):
		direction = 1
		attack_direction = 1
		$Sprite.flip_h = false
		$WeaponHitbox.position.x = 90
	elif Input.is_action_pressed("left") and (not is_raking or is_blowing):
		direction = -1
		attack_direction = -1
		$Sprite.flip_h = true
		$WeaponHitbox.position.x = -90
	else:
		direction = 0
	
	velocity.x = direction * (speed*modify_speed) * int(can_move) # * delta
	var animation = "RUN" if velocity.x != 0  else "IDLE"
	
	
	$Sprite.flip_v = false
	if not is_hitted and not is_attacking and (not is_raking or is_blowing)\
	and not is_dead and not is_aiming:
		state_machine.travel(animation)
# ------------------------------------------------------------------------------

func crouch(): # CROUCH
	if (Input.is_action_pressed("crouch") and not is_hitted) or not can_stand_up:
		is_crouching = true
		$CollisionShape2D.position.y = 35
		$CollisionShape2D.scale.y = 0.825
		var animation = "CRAWLING" if velocity.x != 0  else "CRAWLING_STAND"
		state_machine.travel(animation)
		velocity.x = direction * speed / 1.8
		
	else:
		is_crouching = false
		$CollisionShape2D.position.y = 22
		$CollisionShape2D.scale.y = 1
# ------------------------------------------------------------------------------

func attack(): # LIGHT ATTACK, fast but low dmg,
	if has_learned_attack:
		if Input.is_action_just_pressed("attack") and not is_attacking and not is_blocking:
			is_attacking = true
			$AnimationTree.set("parameters/ATTACK/blend_position", attack_direction)
			if state_machine.get_current_node() != "HOLD_PEBBLE":
				state_machine.travel('ATTACK')
			
			if attack_timer.time_left <= 0.0:
				attack_timer = get_tree().create_timer(0.35)
				if not is_yield_paused:
					yield(attack_timer, "timeout")
					if enemy and can_attack:
						enemy.hit(damage)
					
					is_attacking = false
# ------------------------------------------------------------------------------

func heavy_attack(delta): # HEAVY ATTACK, slow but high dmg
	if not is_crouching and not is_attacking and not is_blocking\
	and not is_aiming and not is_raking:
		if has_learned_heavy_attack and heavy_attack_counter > 0:
			var current_animation = state_machine.get_current_node()
			if Input.is_action_just_pressed("heavy_attack"):
				if current_animation != 'HEAVY_ATTACK':
					$AnimationTree.set("parameters/HEAVY_ATTACK/blend_position", attack_direction)
					state_machine.travel('HEAVY_ATTACK')
					Global.level_root().find_node("UserInterface").scale_unique_leaf(0.6, 0.9)
					is_attacking = true
					heavy_attack_counter -= 1

					if heavy_attack_timer.time_left <= 0.0:
						heavy_attack_timer = get_tree().create_timer(0.3)
						if not is_yield_paused:
							yield(heavy_attack_timer, "timeout")

							if breakable_stone:
								breakable_stone.hit()
								heavy_attack_counter += 1
								breakable_stone = null


							if enemy and can_attack:
								enemy.is_heavy_attacked = true
								enemy.hit(damage)
								enemy.jump_back()

							is_attacking = false
# ------------------------------------------------------------------------------

func blowing(delta):
	if heavy_attack_counter > 0:
		if Input.is_action_pressed("heavy_attack") and Input.is_action_pressed("rake") and has_learned_leaf_blower:
			blowing_time += delta/2
			mouse_position = get_local_mouse_position()
			if not is_blowing:
				is_blowing = true
				wind = WIND_PATH.instance()
	
				wind.z_index = 1
				self.call_deferred("add_child", wind)
				
			var dist = self.position - get_global_mouse_position()
			var x_dir = 1 if dist.x > 0 else -1
			wind.impulse = Vector2(-1500*x_dir, -1000)
			
			var center = OS.get_screen_size()/2
			var deg = rad2deg(center.angle_to(mouse_position))
			wind.global_position = self.position - (dist/10)
			wind.rotation_degrees = deg+30
			for collision in wind.get_children():
				if collision is CollisionShape2D:
					collision.disabled = not collision.disabled
			
			if blowing_time >= 2.5:
				was_blowing = true
				blowing_time = 0.0
				heavy_attack_counter -= 1
				
	if heavy_attack_counter == 0 or Input.is_action_just_released("heavy_attack") or \
	Input.is_action_just_released("rake"):
		if is_instance_valid(wind):
			wind.call_deferred("queue_free")
		is_aiming = false
		is_blowing = false
		
	if not is_blowing and was_blowing:
		self.recharge_leaf_blower(delta)
# ------------------------------------------------------------------------------

func recharge_leaf_blower(delta):
	blowing_time += delta
	if heavy_attack_counter < heavy_attack_increment:
		if blowing_time >= 3.0:
			blowing_time = 0.0
			heavy_attack_counter += 1
			was_blowing = false
# ------------------------------------------------------------------------------

func shoot():
	if Input.is_action_pressed("shoot") and pebble_counter > 0 and not is_crouching:
		can_move = false
		is_aiming = true
		mouse_position = get_local_mouse_position()
		var animation = "SLINGSHOT" if has_slingshot else "PEBBLE"
		state_machine.travel("HOLD_" + animation)
		
		if Input.is_action_just_pressed("attack"):
			state_machine.travel("RELEASE_" + animation)
			if throw_timer.time_left <= 0.0:
				throw_timer = get_tree().create_timer(0.3)
				if not is_yield_paused:
					yield(throw_timer, "timeout")
					can_move = true
			
					var pebble = PEBBLE_PATH.instance()
					get_parent().add_child(pebble)
					pebble.position = $Position2D.global_position
					
					if has_slingshot:
						pebble.can_damage = true
						
					if Global.level_root().filename != "res://Level/CaveDuel/Cave duel.tscn":
						pebble_counter -= 1
						get_parent().find_node("UserInterface").update_pebbles(1, "minus", pebble_counter)
			
	if Input.is_action_just_released("shoot"):
		can_move = true
		is_aiming = false
# ------------------------------------------------------------------------------

func block(): # BLOCK DAMAGE
	if has_learned_blocking:
		if Input.is_action_just_pressed("block"):
			state_machine.travel('BLOCKING')
			
			if can_jump:
				can_move = false
			is_blocking = true
			
			if block_timer.time_left <= 0.0:
				block_timer = get_tree().create_timer(0.7)
				if not is_yield_paused:
					yield(block_timer, "timeout")
					can_move = true
					is_blocking = false
# ------------------------------------------------------------------------------

func rake(): # RAKE LEAVES TO CREATE PILE OF LEAVES
	if has_learned_raking:
		if Input.is_action_just_released("rake"):
			is_raking = false
			$AnimationTree.active = false
			$AnimationTree.active = true
			
		if Input.is_action_pressed("rake") and not is_crouching \
		and not is_hitted and not is_blowing:
			is_raking = true
			
			if Input.is_action_pressed("right"):
				direction = -1
				$Sprite.flip_h = true
			if Input.is_action_pressed("left"):
				direction = 1
				$Sprite.flip_h = false
			
			velocity.x = -direction * speed / 2
			
			var standing_direction = 1 if $Sprite.flip_h else -1
			var dir = standing_direction if direction == 0 else -direction
			
			$AnimationTree.set("parameters/RAKING/blend_position", dir)
			state_machine.travel('RAKING')
			for index in $LeavesCollector.get_slide_count():
				var collision = $LeavesCollector.get_slide_collision(index)
				if collision.collider.is_in_group("leaves"):
					collision.collider.apply_central_impulse(collision.normal * 20)
# ------------------------------------------------------------------------------

func hit(var dmg):
	if not is_dead:
		Global.level_root().find_node("UserInterface") \
		.update_health(dmg, 'minus', health, max_health)
		health -= dmg
		is_hitted = true
		
		if health > 1:
			var current_animation = state_machine.get_current_node()
			if current_animation == 'HEAVY_ATTACK':
				heavy_attack_counter += 1
				
			state_machine.travel('HIT')
		if not is_yield_paused:
			yield(get_tree().create_timer(0.95, false), "timeout")
			is_hitted = false
# ------------------------------------------------------------------------------

func die(): # CHARACTER DIES
	is_dead = true
	health = 0
	set_collision_layer_bit(1, false)
	self.velocity = Vector2.ZERO
	state_machine.travel('DEATH')
	Global.is_yield_paused = true
	# Load checkpoint
	if Global.level_root().name != "TutorialLevel":
		SaveLoad.load_from_slot("slot_4")
	yield(get_tree().create_timer(2.2, false), "timeout")
	$AnimationTree.active = false
# ------------------------------------------------------------------------------

func save(): # SAVE VARIABLES IN DICTIONARY
	var saved_data = {
		"health":health,
		"max_health":max_health,
		"pebble_counter":pebble_counter,
		"acorn_counter":acorn_counter,
		"heavy_attack_counter":heavy_attack_counter,
		"speed":speed,
		"damage":damage,
		"has_slingshot":has_slingshot,
		"has_learned_attack":has_learned_attack,
		"has_learned_heavy_attack":has_learned_heavy_attack,
		"heavy_attack_increment":heavy_attack_increment,
		"has_learned_raking":has_learned_raking,
		"has_learned_blocking":has_learned_blocking
	}
	return saved_data
# ------------------------------------------------------------------------------

func _on_WeaponHitbox_body_entered(body):
	# collision_layer_bit 2 = Enemy
	if body.get_collision_layer_bit(2):
		enemy = body if body.name != "Shield" else body.get_parent()
		can_attack = true
	elif body.get_collision_layer_bit(7) and not "Shield" in body.name:
		breakable_stone = body
# ------------------------------------------------------------------------------

func _on_WeaponHitbox_body_exited(body):
	# collision_layer_bit 2 = Enemy
	if body.get_collision_layer_bit(2):
		enemy = null
		can_attack = false
# ------------------------------------------------------------------------------

func _draw(): # DRAW LINE BETWEEN MOUOSE AND VLADIMIR
	if is_aiming or is_blowing:
		$Sprite.flip_h = true if mouse_position.x < 0 else false
		draw_line(Vector2(0, 0), mouse_position, Color(1.0, 1.0, 1.0, 0.3), 8.0)
# ------------------------------------------------------------------------------

func set_values(data):
	for value in data:
		if value == "pos" or \
			value == "file" or \
			value == "parent":
			continue
#		print(typeof(value)," - ",value,": ",data[value])
		self.set(value, data[value])
# ------------------------------------------------------------------------------

func _on_Ceiling_body_entered(body):
	# detect if vladimir can stand up
	# if something above him he can't
	can_stand_up = false
# ------------------------------------------------------------------------------

func _on_Ceiling_body_exited(body):
	can_stand_up = true
# ------------------------------------------------------------------------------

func stop_moving_during_cutsene():
	self.is_moving = false
	self.velocity = self.GRAVITY
	self.state_machine.travel("IDLE")
