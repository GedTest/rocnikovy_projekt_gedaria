class_name Guardian, "res://Enemy/E-Test/GuardianEdmund.png"
extends Enemy


export (int) var dir
export (int) var starting_position

var turn_around_timer = null

var can_move_from_position = true
var is_hitted = false


func _ready():
	death_anim_time = 2.4
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

func move(): # MOVE
	if !is_dead:
		
		$AnimationTree.set("parameters/RUN/blend_position", is_blocking)
		# IF THERE ISN'T PLAYER GUARD POSITION
		if !has_player:
			# HE LOST PLAYER FROM SIGH, HE GOES TO THE GUARD POSITION
			if int(position.x) == starting_position:
				$AnimationTree.set("parameters/STANDING/blend_position", is_blocking)
				state_machine.travel('STANDING')
				can_move_from_position = false
				
			if int(position.x) or int(position.x) != starting_position:
				if int(position.x) > starting_position:
					direction = -1
					$WallDetection.position.x = -90
					state_machine.travel('RUN')
				elif int(position.x) < starting_position:
					direction = 1
					$WallDetection.position.x = 90
					state_machine.travel('RUN')
				
		# FOLLOW PLAYER OR NOT
		if has_player:
			# PLAYER IS HIDING
			if player.is_hidden:
				$HitRay.enabled = false
				has_player = false
				player = null
				$Shield/CollisionShape2D.disabled = true
				return
				
			if is_blocking:
				$Shield/CollisionShape2D.disabled = false
			can_move_from_position = true if distance > 125 else false
			
			# MOVE TOWARDS PLAYER (RIGHT)
			if player.position.x <= position.x+FoV and player.position.x > position.x:
				if !can_attack:
					direction = 1
					$Shield.position.x = 75
					$Sprite.flip_h = false
					$HitRay.cast_to.x = FoV
					if !is_hitted:
						is_hitted = false
						state_machine.travel('RUN')
			
			# MOVE TOWARDS PLAYER (LEFT)
			elif player.position.x >= position.x-FoV and player.position.x < position.x:
				if !can_attack:
					direction = -1
					$Shield.position.x = -75
					$Sprite.flip_h = true
					$HitRay.cast_to.x = -FoV
					if !is_hitted:
						is_hitted = false
						state_machine.travel('RUN')
					
			# IF RUNNING FOR TOO MUCH LONG GO BACKWARDS
			if position.x < starting_position or position.x > starting_position:
				if turn_around_timer.time_left <= 0.0:
					turn_around_timer = get_tree().create_timer(6.0, false)
					if !is_yield_paused:
						yield(turn_around_timer, "timeout")
		
		velocity.x = speed * direction * int(can_move_from_position) * int(is_moving)
# ------------------------------------------------------------------------------

func move_in_range(from, to):
	if int(position.x) < from+1:
		starting_position = to
		dir = 1
		direction = 1
		$Shield.position.x = 75
		$Sprite.flip_h = false
		$HitRay.cast_to.x = FoV
		
	if int(position.x) > to-10:
		starting_position = from
		dir = -1
		direction = -1
		$Shield.position.x = -75
		$Sprite.flip_h = true
		$HitRay.cast_to.x = -FoV
# ------------------------------------------------------------------------------

func hit(dmg):
	is_hitted = true
	$AnimationTree.set("parameters/HIT/blend_position", is_blocking)
	
	if !is_blocking:
		# CALLING THE "BASE FUNTCION" FIRST
		.hit(dmg)
	
	# KNOCKBACK WHILE BLOCKING
	if is_blocking and int(position.x) != starting_position and has_player:
		hit_in_row += 1 if dmg < 5 else 3
		is_moving = false
		state_machine.travel("HIT")
		
		var jump_direction = 1 if player.position.x - self.position.x > 0 else -1
		self.jump_back(player, 100, 0.08, jump_direction)
		yield(get_tree().create_timer(1.0), "timeout")
		is_moving = true
# ------------------------------------------------------------------------------

func attack(): # DO ATTACK
	if !is_dead and !is_attacking:
		can_move_from_position = false
		$AnimationTree.set("parameters/ATTACK/blend_position",direction)
		$AnimationTree.set("parameters/STANDING/blend_position", is_blocking)
		state_machine.travel('ATTACK')
		
		if has_player:
			if !player.is_dead and can_attack:
				is_attacking = true
				if !player.is_blocking:
					player.hit(damage)
					print("Vladimir's health: ", player.health)
					
		if attack_timer.time_left <= 0.0:
			attack_timer = get_tree().create_timer(2.3 , false)
			if !is_yield_paused:
				yield(attack_timer, "timeout")
				is_attacking = false
				can_move_from_position = true
