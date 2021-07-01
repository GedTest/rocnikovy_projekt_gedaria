extends Enemy


export (bool) var can_turn_around = true
export (bool) var is_able_to_roll = true
enum Type {
	ERNEST,
	ERWIN,
}

export(Type) var type = Type.ERWIN

var turn_around_timer = null
var do_barrel_roll_timer = null
var cooldown_roll_timer = null

var sprite = null

var has_player_before = false
var is_reversed = false
var can_roll = false


func _ready():
	sprite = $Sprite2 if type == Type.ERNEST else $Sprite3
	$Sprite2.visible = true if type == Type.ERNEST else false
	$Sprite3.visible = true if type == Type.ERWIN else false
	death_anim_time = 2.6
	hit_anim_time = 0.5
	turn_around_timer = get_tree().create_timer(0.0, false)
	do_barrel_roll_timer = get_tree().create_timer(0.0, false)
	cooldown_roll_timer = get_tree().create_timer(0.0, false)
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _physics_process(delta):
	if !is_dead:
		is_reversed = true if direction == -1 else false
		
		if has_player and distance <= 150:
			if cooldown_timer.time_left <= 0.0:
				cooldown_timer = get_tree().create_timer(2.6, false)
				if !is_yield_paused:
					yield(cooldown_timer, "timeout")
					attack()
				
		if cooldown_roll_timer.time_left <= 0.0 and !can_attack and is_able_to_roll:
			if !is_yield_paused:
				cooldown_roll_timer = get_tree().create_timer(6.0, false)
				yield(cooldown_roll_timer, "timeout")
				can_roll = true
		
		# DO A BARREL ROLL
		if is_able_to_roll:
			if has_player_before and !is_attacking and distance <= 300 and can_roll:
				position.x += 10 * direction
				$HitRay.enabled = false
				state_machine.travel("FLIP")
			
				if do_barrel_roll_timer.time_left <= 0.0:
					do_barrel_roll_timer = get_tree().create_timer(0.4, false)
					if !is_yield_paused:
						yield(do_barrel_roll_timer, "timeout")
						$HitRay.enabled = true
						has_player_before = false
						sprite.flip_h = !sprite.flip_h 
						$HitRay.cast_to.x = -$HitRay.cast_to.x
						can_roll = false
# ------------------------------------------------------------------------------

# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func move(var from, var to): # MOVE
	if !is_dead:
		if is_moving:
			state_machine.travel('run')
	# MOVE FROM 'A' TO 'B'
		if !has_player and !has_player_before:
			$HitRay.enabled = true
			
			if position.x > to:
				direction = -1
				sprite.flip_h = true
				$HitRay.cast_to.x = -FoV
				$WallDetection.position.x = -65
			elif position.x < from:
				direction = 1
				sprite.flip_h = false
				$HitRay.cast_to.x = FoV
				$WallDetection.position.x = 65
				
			# LOOK AROUND FOR PLAYER
			if turn_around_timer.time_left <= 0.0 and !has_player:
				turn_around_timer = get_tree().create_timer(5.0, false)
				if !is_yield_paused:
					yield(turn_around_timer, "timeout")
					turn_around()
				
	# FOLLOW PLAYER OR NOT
		if has_player:
			# PLAYER IS HIDING
			if player.is_hidden:
				$HitRay.enabled = false
				has_player = false
				player = null
				return
				
			if is_able_to_roll:
				has_player_before = true
			if !can_roll or !is_able_to_roll:
				is_moving = true if distance > 125 else false
			
			# MOVE TOWARDS PLAYER (RIGHT)
			if player.position.x <= position.x+FoV and player.position.x > position.x:
				if !can_attack:
					direction = 1
					sprite.flip_h = false
					$HitRay.cast_to.x = FoV
					$WallDetection.position.x = 65
			
			# MOVE TOWARDS PLAYER (LEFT)
			elif player.position.x >= position.x-FoV and player.position.x < position.x:
				if !can_attack:
					direction = -1
					sprite.flip_h = true
					$HitRay.cast_to.x = -FoV
					$WallDetection.position.x = -65
					
			# IF RUNNING FOR TOO MUCH LONG
			if position.x < from or position.x > to:
				if turn_around_timer.time_left <= 0.0:
					turn_around_timer = get_tree().create_timer(2.0, false)
					if !is_yield_paused:
						yield(turn_around_timer, "timeout")
						sprite.flip_h = !sprite.flip_h 
						$HitRay.cast_to.x = -$HitRay.cast_to.x 
			
		velocity.x = speed * direction * int(is_moving)
# ------------------------------------------------------------------------------

func attack(): # DO ATTACK
	if !is_dead and !is_attacking:
		is_moving = false
		$AnimationTree.set("parameters/ATTACK/blend_position", direction)
		state_machine.travel('ATTACK')
		
		if attack_timer.time_left <= 0.0:
			attack_timer = get_tree().create_timer(0.6, false)
			if !is_yield_paused:
				yield(attack_timer, "timeout")
				if has_player:
					if !player.is_dead and can_attack:
						is_attacking = true
						if !player.is_blocking:
							player.hit(damage)
						
				if attack_timer.time_left <= 0.0:
					attack_timer = get_tree().create_timer(1.0, false)
					if !is_yield_paused:
						yield(attack_timer, "timeout")
						is_attacking = false
						is_moving = true
# ------------------------------------------------------------------------------

func turn_around(): # LOOK BACK AND FORTH
	if !is_dead and can_turn_around:
		state_machine.travel('STANDING')
		sprite.flip_h = !sprite.flip_h
		is_moving = false
		$HitRay.cast_to.x = -$HitRay.cast_to.x
		$WallDetection.position.x *= -1
		
		if turn_around_timer.time_left <= 0.0:
			turn_around_timer = get_tree().create_timer(0.75, false)
			if !is_yield_paused:
				yield(turn_around_timer, "timeout")
				is_moving = true
				
				if !has_player:
					sprite.flip_h = !sprite.flip_h
					$HitRay.cast_to.x = -$HitRay.cast_to.x
					$WallDetection.position.x *= -1
				state_machine.travel('run')
# ------------------------------------------------------------------------------

func save():
	things_to_save.is_focused = self.is_focused
	.save()
	return things_to_save
