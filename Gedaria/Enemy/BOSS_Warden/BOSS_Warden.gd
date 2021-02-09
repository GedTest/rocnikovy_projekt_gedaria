class_name BOSS_Warden, "res://Enemy/BOSS_Warden/BOSS_Warden.png"
extends Enemy


var StickPath = preload("res://Enemy/BOSS_Warden/Stick.tscn")
var BirdPath = preload("res://Level/Prologue/Bird.tscn").instance()

var can_throw = false
var is_throwing = false
var is_done_once = true
var can_jump = true
var is_in_air = false
var is_hitted = false

var boost = 1
var max_health

var throw_timer = null
var hit_in_row_timer = null


func _ready():
	FoV = 1000
	state_machine = $AnimationTree.get("parameters/playback")
	max_health = health
	is_blocking = true
	
	cooldown_timer = get_tree().create_timer(0.0, false)
	hit_in_row_timer = get_tree().create_timer(0.0, false)
	throw_timer = get_tree().create_timer(0.0, false)
	
	yield(get_tree().create_timer(10.0, false), "timeout")
	$Dialog.text = Languages.languages[Global.prefered_language]["boss_warden_quote"]
	$Dialog.show()
	yield(get_tree().create_timer(4.0, false), "timeout")
	$Dialog.queue_free()
# ------------------------------------------------------------------------------

func _process(delta):
	if !is_dead and !is_throwing:
		# DAMPING VELOCITY FROM JUMP IMPULSE
		if !can_jump and is_in_air:
			speed += 35
			velocity.y += 12
		
		# if he reach ground and have 0 speed then reset the speed
		elif can_jump and is_in_air:
			speed = 200
			is_in_air = false
	
		# 2ND PHASE OF BOSSFIGHT
		if health == max_health / 2 and is_done_once:
			get_parent().find_node("Branch").shake()
			get_parent().add_child(BirdPath)
			BirdPath.position = Vector2(1920, 400)
			jump()
			is_done_once = false
			can_throw = true
			
		# is he in the air or on the ground ?
		can_jump = true if $GroundRay.is_colliding() else false
		
		# does he see the player ?
		if $HitRay.is_colliding() and $HitRay.get_collider().name == "Vladimir" or $HitRay2.is_colliding() and $HitRay2.get_collider().name == "Vladimir":
			player = $HitRay.get_collider() if $HitRay.get_collider() != null else $HitRay2.get_collider()
			has_player = true
		else:
			player = null
			has_player = false
		
		if health > max_health / 2:
		# When he got 2 hits in row he is vulnerable to take damage
			if hit_in_row == 2:
				is_blocking = false
				
			if hit_in_row > 0 and hit_in_row < 2:
			#	is_blocking = true
				if hit_in_row_timer.time_left <= 0.0:
					hit_in_row_timer = get_tree().create_timer(3.5, false)
					yield(hit_in_row_timer, "timeout")
					is_moving = true
					hit_in_row = 0
		# If there weren't 2 hits in a row, he is in blocking state
			elif hit_in_row != 2 and is_attacking:
				is_blocking = true
				
		elif !is_hitted:
			is_blocking = true
			
		velocity = move_and_slide(velocity)
# ------------------------------------------------------------------------------

func move(): # HANDLE MOVEMENT
	if !is_dead:
		$AnimationTree.set("parameters/JUMP/blend_position", direction)
		
		if has_player and !player.is_dead:
			#distance = abs(position.x - player.position.x)
			if distance <= 135 and !is_attacking and !(can_throw or is_throwing):
				attack()
				
			if health <= max_health / 2:
				if distance < 350 and can_throw:
					jump()
					
				if distance > 350 and distance < 700 and can_throw:
					throw()
			else:
				dash()
		
		# MOVE FROM 'A' TO 'B'
		if !has_player and is_moving:
			if position.x > to:
				direction = -1
				$Sprite.flip_h = false
				$HitRay.cast_to.x = -FoV
				$HitRay2.cast_to.x = -FoV
			
			elif position.x < from:
				direction = 1
				$Sprite.flip_h = true
				$HitRay.cast_to.x = FoV
				$HitRay2.cast_to.x = FoV
		
		velocity.x = speed * direction * boost * int(is_moving)
# ------------------------------------------------------------------------------		

func attack(): # PRIMARY ATTACK - THRESH
	is_moving = false
	$AnimationTree.set("parameters/ATTACK/blend_position", direction)
	state_machine.travel('ATTACK')
	
	if !player.is_dead:
		if player and has_player and can_attack:
			is_attacking = true
			if !player.is_blocking:
				player.hit(damage)
				print("Vladimir's health: ", player.health)
			
		if attack_timer.time_left <= 0.0 and !is_throwing:
			attack_timer = get_tree().create_timer(1.2, false)
			yield(attack_timer, "timeout")
			if !has_player:
				is_moving = true
			
		if cooldown_timer.time_left <= 0.0 and !is_throwing:
			cooldown_timer = get_tree().create_timer(2.8, false)
			yield(cooldown_timer, "timeout")
			is_moving = true
			is_attacking = false
# ------------------------------------------------------------------------------

func dash(): # SPEEDS UP AND DASHes TOWARD THE PLAYER
	if !is_attacking:
		if distance > 450:
			boost = 2
		else:
			boost = 1
# ------------------------------------------------------------------------------

func jump(): # JUMP IN DISTANCE SO HE CAN THROW
	if !is_hitted:
		# ensure the he can't jump out of screen
		if position.x > from -200 and position.x < to +200:
			speed = 200
			
			speed -= 900
			velocity.y = -1200
			yield(get_tree().create_timer(0.5, false), "timeout")
			is_in_air = true
			if can_jump:
				is_moving = true
# ------------------------------------------------------------------------------

func throw(): # SECONDARY ATTACK - THROW
	can_throw = false
	is_throwing = true
	is_moving = false
	
	$AnimationTree.set("parameters/THROW/blend_position", direction)
	state_machine.travel('THROW')
	if throw_timer.time_left <= 0.0 and !is_attacking:
		throw_timer = get_tree().create_timer(0.6, false)
		yield(throw_timer, "timeout")
	
		# deal the damage by projektil
		throw_timer.time_left = 0.0
		add_child(StickPath.instance())
		
		if throw_timer.time_left <= 0.0 and !is_attacking:
			throw_timer = get_tree().create_timer(3.3, false)
			yield(throw_timer, "timeout")
			if !is_dead:
				state_machine.travel('CATCH')
			can_throw = true
			is_throwing = false
			is_moving = true
# ------------------------------------------------------------------------------

func hit(dmg):
	is_moving = false
	
	if is_blocking:
		hit_in_row += 1
		state_machine.travel('HIT_UNBLOCKABLE')
	
	if !is_blocking:
		$stars.emitting = false
		is_blocking = true
		is_moving = true
		hit_in_row = 0
		.hit(dmg)
