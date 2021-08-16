class_name Guardian, "res://Enemy/E-Test/GuardianEdmund.png"
extends Enemy
"""
Edmund, the guardian
is derived from base enemy class, slow enemy with
lots of health, wielding shield to protect him
"""



export (int) var dir
export (int) var starting_position

var can_move_from_position = true
var has_player_behind = false


func _ready():
	death_anim_time = 2.4
	death_frame = 32
	is_blocking = true
	direction = 0
	hit_in_row = 0
	$HitRay.cast_to.x *= dir
	$HitRay2.cast_to.x *= dir
	can_warn = true
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _physics_process(delta):
	if not is_dead:
		if not is_blocking and has_player and distance <= 150:
			if cooldown_timer.time_left <= 0.0:
				cooldown_timer = get_tree().create_timer(1.0, false)
				if not is_yield_paused:
					yield(cooldown_timer, "timeout")
					self.attack(2.0, 0.6)
	
		if is_heavy_attacked or hit_in_row == 3:
			# BLOCK DAMAGE; ONLY HEAVY ATTACKS CAN BREAK SHIELD
			$Shield.hide()
			$Shield/CollisionShape2D.disabled = true
			is_blocking = false
	else:
		$Shield.hide()
		$Shield/CollisionShape2D.disabled = true
		is_blocking = false
		if not is_yield_paused:
			yield(get_tree().create_timer(death_anim_time+0.3), "timeout")
			$Sprite.frame = death_frame
			$AnimationTree.active = false
# ------------------------------------------------------------------------------

func move():
	# HANDLE ENEMY'S MOVEMENT
	# AND DECIDE IF FOLLOW PLAYER OR NOT
	if not is_dead:
		$AnimationTree.set("parameters/RUN/blend_position", is_blocking)
		if not has_player:
			# IF THERE ISN'T PLAYER GUARD POSITION
			if int(position.x) == starting_position:
				$AnimationTree.set("parameters/STANDING/blend_position", is_blocking)
				state_machine.travel('STANDING')
				can_move_from_position = false
				
			if int(position.x) or int(position.x) != starting_position:
				# HE LOST PLAYER FROM SIGH, HE GOES TO THE GUARD POSITION
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
			if player.is_hidden:
				# PLAYER IS HIDING SO HE CAN'T SEE HIM
				$HitRay.enabled = false
				has_player = false
				player = null
				$Shield/CollisionShape2D.disabled = true
				self.reset_icon()
				$Icon.frame = HIDDEN_ICON
				$Icon.show()
				return
			can_warn = true
			
			if is_blocking:
				$Shield/CollisionShape2D.disabled = false
			can_move_from_position = true if distance > 125 else false
			
			if player.position.x <= position.x+FoV and player.position.x > position.x:
				# MOVE TOWARDS PLAYER (RIGHT)
				if not can_attack:
					direction = 1
					self.turn(direction)
					if not is_hitted:
						is_hitted = false
						state_machine.travel('RUN')
			
			elif player.position.x >= position.x-FoV and player.position.x < position.x:
				# MOVE TOWARDS PLAYER (LEFT)
				if not can_attack:
					direction = -1
					self.turn(direction)
					if not is_hitted:
						is_hitted = false
						state_machine.travel('RUN')
		
		velocity.x = speed * direction * int(can_move_from_position) * int(is_moving)
# ------------------------------------------------------------------------------

func move_in_range(from, to):
	# WHEN GUARDIAN CAN MOVE NOT ONLY STAND IN ONE PLACE
	if int(position.x) < from+1:
		# MOVE RIGHT
		starting_position = to
		direction = 1
		self.turn(direction)
		
	if int(position.x) > to-10:
		# MOVE LEFT
		starting_position = from
		direction = -1
		self.turn(direction)
# ------------------------------------------------------------------------------

func hit(dmg):
	is_hitted = true
	$AnimationTree.set("parameters/HIT/blend_position", is_blocking)
	
	if not is_blocking:
		# CALLING THE "BASE FUNTCION" FIRST
		.hit(dmg)
	
	if $HitRay2.is_colliding():
		has_player_behind = true
		player = $HitRay2.get_collider()
		
	if is_blocking and (has_player or has_player_behind):
		# PUSH PLAYER IN DIRECTION
		if player.position.x <= position.x:
			direction = -1
		elif player.position.x >= position.x:
			direction = 1
			
		self.turn(direction)
		$AdvancedTween.play(0.2, player.position.x, player.position.x+(230*direction))
		
		has_player_behind = false
		player = null
		
		hit_in_row += 1 if dmg < 5 else 3
		is_moving = false
		state_machine.travel("HIT")
		yield(get_tree().create_timer(1.0), "timeout")
		is_moving = true
# ------------------------------------------------------------------------------

func attack(attack_time, cooldown_time):
	$AnimationTree.set("parameters/STANDING/blend_position", is_blocking)
	.attack(attack_time, cooldown_time)
# ------------------------------------------------------------------------------

func turn(direction):
	# FLIP ITS COMPONENT TO CORRESPONDING DIRECTION
	if direction == -1:
		$Shield.position.x = -75
		$Sprite.flip_h = true
		$HitRay.cast_to.x = -FoV
		$HitRay2.cast_to.x = FoV
	elif direction == 1:
		$Shield.position.x = 75
		$Sprite.flip_h = false
		$HitRay.cast_to.x = FoV
		$HitRay2.cast_to.x = -FoV
# ------------------------------------------------------------------------------

func _on_AdvancedTween_advance_tween(sat):
	# KNOCKBACK PLAYER WITH SHIELD
	if has_player:
		player.position.x = sat
# ------------------------------------------------------------------------------
