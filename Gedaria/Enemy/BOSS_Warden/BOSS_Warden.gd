class_name BOSS_Warden, "res://Enemy/BOSS_Warden/BOSS_Warden.png"
extends Enemy
"""
Boss Warden
is derived from base enemy class, he is tutorial boss
and has two attacks - thresh & throw
"""



const STICK_PATH = preload("res://Enemy/BOSS_Warden/Stick.tscn")
const BIRD_PATH = preload("res://Level/Prologue/Bird.tscn")

var can_throw = false
var is_throwing = false
var is_done_once = true
var can_jump = true
var can_move_during_cutscene = true
var is_immune = true
var is_in_air = false
var is_hitted_by_leaf = false

var boost = 1
var max_health

var throw_timer = null


func _ready():
	FoV = 1000
	state_machine = $AnimationTree.get("parameters/playback")
	max_health = health
	
	cooldown_timer = get_tree().create_timer(0.0, false)
	throw_timer = get_tree().create_timer(0.0, false)
	self.say_dialog()
# ------------------------------------------------------------------------------

func say_dialog():
	yield(get_tree().create_timer(20.0, false), "timeout")
	$Dialog.text = Languages.languages[Global.prefered_language]["boss_warden_quote"]
	$Dialog.show()
	yield(get_tree().create_timer(4.5, false), "timeout")
	$Dialog.queue_free()
# ------------------------------------------------------------------------------

func _process(delta):
	if not is_dead and not is_throwing:
		# DAMPING VELOCITY FROM JUMP IMPULSE
		if not can_jump and is_in_air:
			speed += 35
			velocity.y += 12
		
		# IF HE REACH GROUND WITH 0 SPEED RESET SPEED
		elif can_jump and is_in_air:
			speed = 200
			is_in_air = false
	
		# 2ND PHASE OF BOSSFIGHT
		if health == max_health / 2 and is_done_once:
			is_blocking = true
			var bird = BIRD_PATH.instance()
			self.get_parent().add_child(bird)
			bird.position = Vector2(1920, 400)
			self.jump()
			is_done_once = false
			can_throw = true
			
		# IS HE IN THE AIR ?
		can_jump = true if $GroundRay.is_colliding() else false
		
		if $HitRay.is_colliding() and $HitRay.get_collider().name == "Vladimir" \
		or $HitRay2.is_colliding() and $HitRay2.get_collider().name == "Vladimir":
			# PLAYER IS SPOTTED
			player = $HitRay.get_collider() if $HitRay.get_collider() != null else $HitRay2.get_collider()
			has_player = true
		else:
			player = null
			has_player = false
		
		velocity = move_and_slide(velocity)
# ------------------------------------------------------------------------------

func move():
	# HANDLE MOVEMENT
	if not is_dead and can_move_during_cutscene:
		$AnimationTree.set("parameters/JUMP/blend_position", direction)
		
		if has_player and not player.is_dead:
			if distance <= 135 and not is_attacking and not(can_throw or is_throwing):
				self.attack_player()
				
			if health <= max_health / 2:
				if distance < 350 and can_throw:
					self.jump()
					
				if distance > 350 and distance < 700 and can_throw:
					self.throw()
			else:
				self.dash()
		
		if not has_player and is_moving:
			if position.x > to:
				# MOVE FROM LEFT
				direction = -1
				$Sprite.flip_h = false
				$HitRay.cast_to.x = -FoV
				$HitRay2.cast_to.x = -FoV
			
			elif position.x < from:
				# MOVE RIGHT
				direction = 1
				$Sprite.flip_h = true
				$HitRay.cast_to.x = FoV
				$HitRay2.cast_to.x = FoV
		
		velocity.x = speed * direction * boost * int(is_moving)
# ------------------------------------------------------------------------------		

func attack_player():
	# PRIMARY ATTACK - THRESH
	is_moving = false
	$AnimationTree.set("parameters/ATTACK/blend_position", direction)
	state_machine.travel('ATTACK')
	
	if not player.is_dead:
		if player and has_player and can_attack:
			is_attacking = true
			if not player.is_blocking:
				player.hit(damage)
				print("Vladimir's health: ", player.health)
			
		if attack_timer.time_left <= 0.0 and not is_throwing:
			attack_timer = get_tree().create_timer(1.2, false)
			yield(attack_timer, "timeout")
			if not has_player:
				is_moving = true
			
		if cooldown_timer.time_left <= 0.0 and not is_throwing:
			cooldown_timer = get_tree().create_timer(2.8, false)
			yield(cooldown_timer, "timeout")
			is_moving = true
			is_attacking = false
# ------------------------------------------------------------------------------

func dash():
	# SPEEDS UP AND DASHES TOWARD THE PLAYER
	if not is_attacking:
		if distance > 450:
			boost = 2
		else:
			boost = 1
# ------------------------------------------------------------------------------

func jump():
	# JUMP IN DISTANCE SO HE CAN THROW
	if not is_hitted_by_leaf:
		# ENSURE THAT HE CAN'T JUMP OUT OF SCREEN
		if position.x > from +200 and position.x < to -200:
			speed = 200
			
			speed -= 900
			velocity.y = -1200
			yield(get_tree().create_timer(0.5, false), "timeout")
			is_in_air = true
			if can_jump:
				is_moving = true
# ------------------------------------------------------------------------------

func throw():
	# SECONDARY ATTACK - THROW
	can_throw = false
	is_throwing = true
	is_moving = false
	
	$AnimationTree.set("parameters/THROW/blend_position", direction)
	state_machine.travel('THROW')
	if throw_timer.time_left <= 0.0 and not is_attacking:
		throw_timer = get_tree().create_timer(0.6, false)
		yield(throw_timer, "timeout")
	
		# SPAWN PROJECTILE
		throw_timer.time_left = 0.0
		var stick = STICK_PATH.instance()
		add_child(stick)
		var pos = $Top.position if randi()%2==0 else $Bottom.position
		stick.position = pos
		
		if throw_timer.time_left <= 0.0 and not is_attacking:
			throw_timer = get_tree().create_timer(3.3, false)
			yield(throw_timer, "timeout")
			if not is_dead:
				state_machine.travel('CATCH')
			can_throw = true
			is_throwing = false
			is_moving = true
			$HitRay.enabled = true
# ------------------------------------------------------------------------------

func hit(dmg):
	if not is_immune:
		is_moving = false
		
		if is_blocking:
			self.kick()
			state_machine.travel('HIT_UNBLOCKABLE')
		
		if not is_blocking:
			hit_in_row += 1
			if hit_in_row == 3:
				hit_in_row = 0
				self.kick()
				return
			
			$stars.emitting = false
			is_moving = true
			.hit(dmg)
# ------------------------------------------------------------------------------

func kick():
	# KICK PLAYER BACK SO BOSS CAN ATTACK
	if self.has_player:
		var kick_direction = 1 if player.position.x - self.position.x > 0 else -1
		var x = 350 * kick_direction
		$Tween.interpolate_property(player, "position", player.position, Vector2(player.position.x+x, player.position.y), 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
		$Tween.start()
