extends Enemy


export (int) var dir
export (int) var starting_position

var turn_around_timer = null

var can_move_from_position = true


func _ready():
	death_anim_time = 3.0
	is_blocking = true
	turn_around_timer = get_tree().create_timer(0.0, false)
	direction = 0
	hit_in_row = 0
	$HitRay.cast_to.x *= dir
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
		if is_heavy_attacked or hit_in_row == 3:
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
				$WallDetection.position.x = -90
				state_machine.travel('run')
			elif int(position.x) < starting_position:
				direction = 1
				$WallDetection.position.x = 90
				state_machine.travel('run')
			else:
				state_machine.travel('standing')
				can_move_from_position = false
				
		# FOLLOW PLAYER OR NOT
		if has_player:
			# PLAYER IS HIDING
			if player.is_hidden:
				$HitRay.enabled = false
				has_player = false
				player = null
				$Shield/CollisionShape2D.disabled = true
				return
			
			$Shield/CollisionShape2D.disabled = false
			can_move_from_position = true if distance > 125 else false
			
			# MOVE TOWARDS PLAYER (RIGHT)
			if player.position.x <= position.x+FoV and player.position.x > position.x:
				if !can_attack:
					direction = 1
					$Shield.position.x = 75
					$Sprite.flip_h = true
					$HitRay.cast_to.x = FoV
					$BackwardRay.cast_to.x = -110
			
			# MOVE TOWARDS PLAYER (LEFT)
			elif player.position.x >= position.x-FoV and player.position.x < position.x:
				if !can_attack:
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
		
		velocity.x = speed * direction * int(can_move_from_position)
# ------------------------------------------------------------------------------

func move_in_range(from, to):
	if int(position.x) < from+1:
		starting_position = to
		dir = 1
		direction = 1
		$Shield.position.x = 75
		$Sprite.flip_h = true
		$HitRay.cast_to.x = FoV
		$BackwardRay.cast_to.x = -110
		
	if int(position.x) > to-10:
		starting_position = from
		dir = -1
		direction = -1
		$Shield.position.x = -75
		$Sprite.flip_h = false
		$HitRay.cast_to.x = -FoV
		$BackwardRay.cast_to.x = 110
# ------------------------------------------------------------------------------

func hit(dmg):
	if !is_blocking:
		# CALLING THE "BASE FUNTCION" FIRST
		.hit(dmg)
	
	hit_in_row += 1 if dmg < 5 else 3
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
		can_move_from_position = false
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
				#speed = movement_speed
				is_attacking = false
				can_move_from_position = true
