class_name Patroller, "res://Enemy/E-Test/PatrollerErwin.png"
extends Enemy
"""
Ernest & Erwin, the twins
are derived from base enemy class, fast enemy with
medium health and damage
"""


const WALK1_SFX = preload("res://sfx/krok vojáka 1.wav")
const WALK2_SFX = preload("res://sfx/krok vojáka 2.wav")

enum Type {
	ERNEST,
	ERWIN,
}
export (bool) var can_turn_around = true
export (bool) var is_able_to_roll = true
export(Type) var type = Type.ERWIN

var do_barrel_roll_timer = null
var cooldown_roll_timer = null

var sprite = null

var has_player_before = false
var can_roll = false


func _ready():
	self.set_enemy()
	death_anim_time = 1.6
	hit_anim_time = 0.5
	can_warn = true
	do_barrel_roll_timer = get_tree().create_timer(0.0, false)
	cooldown_roll_timer = get_tree().create_timer(0.0, false)
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _physics_process(delta):
	if not is_dead:
		if has_player and distance <= 150:
			if cooldown_timer.time_left <= 0.0:
				cooldown_timer = get_tree().create_timer(2.6, false)
				if not is_yield_paused:
					yield(cooldown_timer, "timeout")
					.attack(1.0, 0.45)
				
		if cooldown_roll_timer.time_left <= 0.0 and not can_attack and is_able_to_roll:
			if not is_yield_paused:
				cooldown_roll_timer = get_tree().create_timer(6.0, false)
				yield(cooldown_roll_timer, "timeout")
				can_roll = true
		
		# DO A BARREL ROLL
		if is_able_to_roll:
			if has_player_before and not is_attacking and distance <= 300 and can_roll:
				position.x += 10 * direction
				$HitRay.enabled = false
				state_machine.travel("FLIP")
			
				if do_barrel_roll_timer.time_left <= 0.0:
					do_barrel_roll_timer = get_tree().create_timer(0.4, false)
					if not is_yield_paused:
						yield(do_barrel_roll_timer, "timeout")
						$HitRay.enabled = true
						has_player_before = false
						sprite.flip_h = not sprite.flip_h 
						$HitRay.cast_to.x = -$HitRay.cast_to.x
						can_roll = false
	if is_dead:
		if not is_yield_paused:
			yield(get_tree().create_timer(death_anim_time+0.3), "timeout")
			sprite.frame = death_frame
			$AnimationTree.active = false
# ------------------------------------------------------------------------------

# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func move(var from, var to): # MOVE
	if not is_dead:
		if is_moving:
			state_machine.travel('run')
	# MOVE FROM 'A' TO 'B'
		if not has_player and not has_player_before:
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
			if turn_around_timer.time_left <= 0.0 and not has_player:
				turn_around_timer = get_tree().create_timer(5.0, false)
				if not is_yield_paused:
					yield(turn_around_timer, "timeout")
					self.turn_around()
				
	# FOLLOW PLAYER OR NOT
		if has_player:
			# PLAYER IS HIDING
			if player.is_hidden:
				$HitRay.enabled = false
				has_player = false
				player = null
				self.reset_icon()
				$Icon.frame = HIDDEN_ICON
				$Icon.show()
				return
			can_warn = true
				
			if is_able_to_roll:
				has_player_before = true
			if (not can_roll or not is_able_to_roll) and not is_hitted:
				is_moving = true if distance > 125 else false
			
			# MOVE TOWARDS PLAYER (RIGHT)
			if player.position.x <= position.x+FoV and player.position.x > position.x:
				if not can_attack:
					direction = 1
					sprite.flip_h = false
					$HitRay.cast_to.x = FoV
					$WallDetection.position.x = 65
			
			# MOVE TOWARDS PLAYER (LEFT)
			elif player.position.x >= position.x-FoV and player.position.x < position.x:
				if not can_attack:
					direction = -1
					sprite.flip_h = true
					$HitRay.cast_to.x = -FoV
					$WallDetection.position.x = -65
					
			# IF RUNNING FOR TOO MUCH LONG
			if position.x < from or position.x > to:
				if turn_around_timer.time_left <= 0.0:
					turn_around_timer = get_tree().create_timer(2.0, false)
					if not is_yield_paused:
						yield(turn_around_timer, "timeout")
						sprite.flip_h = not sprite.flip_h 
						$HitRay.cast_to.x = -$HitRay.cast_to.x 
			
		velocity.x = speed * direction * int(is_moving)
# ------------------------------------------------------------------------------

func turn_around(): 
	if not is_dead and can_turn_around:
		# LOOK BACK
		state_machine.travel('STANDING')
		sprite.flip_h = not sprite.flip_h
		is_moving = false
		$HitRay.cast_to.x = -$HitRay.cast_to.x
		$WallDetection.position.x *= -1
		
		if turn_around_timer.time_left <= 0.0:
			turn_around_timer = get_tree().create_timer(0.75, false)
			if not is_yield_paused:
				yield(turn_around_timer, "timeout")
				is_moving = true
				
				if not has_player:
					# LOOK FORWARD
					sprite.flip_h = not sprite.flip_h
					$HitRay.cast_to.x = -$HitRay.cast_to.x
					$WallDetection.position.x *= -1
				state_machine.travel('run')
# ------------------------------------------------------------------------------

func set_enemy():
	# SET DIFFERENT VALUES BASED ON TYPE OF ENEMY
	sprite = $Sprite2 if type == Type.ERNEST else $Sprite3
	$Sprite2.visible = true if type == Type.ERNEST else false
	$Sprite3.visible = true if type == Type.ERWIN else false
	death_frame = 37 if type == Type.ERNEST else 19
# ------------------------------------------------------------------------------

func save():
	things_to_save.is_focused = self.is_focused
	.save()
	return things_to_save
