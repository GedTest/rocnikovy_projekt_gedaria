extends Enemy


export (bool) var is_able_to_jump = true   # bJumping
export (int) var dir
export (int) var starting_position
export (int) var height_level

var turn_around_timer = null
var jump_timer = null

var can_jump = false      # bCanJump
var is_moving = true        # bCanMove


func _ready():
	death_anim_time = 3.0
	$HitRay.cast_to.x *= dir
	is_blocking = true
	turn_around_timer = get_tree().create_timer(0.0, false)
	jump_timer = get_tree().create_timer(0.0, false)
	direction = 0
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _physics_process(delta):
	if !is_dead:
		if has_player and distance <= 150 and !is_blocking:
			if cooldown_timer.time_left <= 0.0:
				cooldown_timer = get_tree().create_timer(1.0, false)
				if !is_yield_paused:
					yield(cooldown_timer, "timeout")
					attack()
	
		# BLOCKING DAMAGE; ONLY HEAVY ATTACKS CAN BREAK BLOCKING
		if is_heavy_attacked:
			$Shield.hide()
			$Shield/CollisionShape2D.disabled = true
			is_blocking = false
	else:
		$Shield.hide()
		$Shield/CollisionShape2D.disabled = true
		is_blocking = false
# ------------------------------------------------------------------------------

# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func move(): # MOVE
	if !is_dead:
		
		# IF THERE ISN'T PLAYER GUARD POSITION
		if !has_player:
			# HE LOST PLAYER FROM SIGH, HE GOES TO THE GUARD POSITION
			if int(position.x) > starting_position:
				direction = -1
				state_machine.travel('run')
			elif int(position.x) < starting_position:
				direction = 1
				state_machine.travel('run')
			else:
				state_machine.travel('standing')
				speed = 0
				
			 # IF HE FALLS OFF THE PLATFORM, HE JUMPS BACK
			if int(position.y) != height_level and is_able_to_jump:
				jump()
			else:
				can_jump = true
				
		# FOLLOW PLAYER OR NOT
		if has_player:
			is_moving = true if distance > 125 else false
			can_jump = is_moving
			# MOVE TOWARDS PLAYER (RIGHT)
			if player.position.x <= position.x+FoV and player.position.x > position.x:
				if !can_attack:
					speed = movement_speed
					direction = 1
					$Shield.position.x = 75
					$Sprite.flip_h = true
					$HitRay.cast_to.x = FoV
					$BackwardRay.cast_to.x = -110
			
			# MOVE TOWARDS PLAYER (LEFT)
			elif player.position.x >= position.x-FoV and player.position.x < position.x:
				if !can_attack:
					speed = movement_speed
					direction = -1
					$Shield.position.x = -75
					$Sprite.flip_h = false
					$HitRay.cast_to.x = -FoV
					$BackwardRay.cast_to.x = 110
					
			# IF RUNNING FOR TOO MUCH LONG GO BACKWARDS
			if position.x < starting_position or position.x > starting_position:
				if turn_around_timer.time_left <= 0.0:
					turn_around_timer = get_tree().create_timer(6.0, false)
					if !is_yield_paused:
						yield(turn_around_timer, "timeout")
		
		velocity.x = speed * direction * int(is_moving)
# ------------------------------------------------------------------------------

func jump(): # JUMP BACK ONTO PLATFORM
	if jump_timer.time_left <= 0.0:
		if can_jump:
			jump_timer = get_tree().create_timer(2.5, false)
			if !is_yield_paused:
				yield(jump_timer, "timeout")
				if !has_player:
					can_jump = false
					velocity.y -= (position.y + height_level) / 1.5
# ------------------------------------------------------------------------------

func hit(dmg):
	if !is_blocking:
		# CALLING THE "BASE FUNTCION" FIRST
		.hit(dmg)
	
	
	var knockbackDistance = 0
	# KNOCKBACK WHILE BLOCKING
	if is_blocking and int(position.x) != starting_position:
		if $BackwardRay.is_colliding() or $BackwardRay2.is_colliding():
			var ray = $BackwardRay if $BackwardRay.is_colliding() else $BackwardRay2
			knockbackDistance = abs(position.x - ray.get_collision_point().x)
		position.x -= (100 - knockbackDistance) * direction
# ------------------------------------------------------------------------------

func attack(): # DO ATTACK
	if !is_dead:
		is_moving = false
		$AnimationTree.set("parameters/ATTACK/blend_position",direction)
		state_machine.travel('ATTACK')
		
		if has_player:
			if !player.is_dead and can_attack and !is_attacking:
				is_attacking = true
				if !player.is_blocking:
					player.hit(damage)
					print("Vladimir's health: ", player.health)
					
		if attack_timer.time_left <= 0.0:
			attack_timer = get_tree().create_timer(1.2, false)
			if !is_yield_paused:
				yield(attack_timer, "timeout")
				speed = movement_speed
				is_attacking = false
				is_moving = true
