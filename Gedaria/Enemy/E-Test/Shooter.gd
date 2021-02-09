extends Enemy


const ProjectilePath = preload("res://Enemy/E-Test/Projectile.tscn")

var turn_around_timer = null


func _ready():
	turn_around_timer = get_tree().create_timer(0.0, false)
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _process(delta):
	if !is_dead:
		# LOOK AROUND FOR PLAYER
		if turn_around_timer.time_left <= 0.0 and !has_player:
			turn_around_timer = get_tree().create_timer(5.0, false)
			if !is_yield_paused:
				yield(turn_around_timer, "timeout")
				turn_around()
		
		direction = 1 if $Sprite.flip_h else -1
		
		if has_player:
			shoot()
# ------------------------------------------------------------------------------

func turn_around(): # LOOK BACK AND FORTH
	if !is_dead:
		$Sprite.flip_h = !$Sprite.flip_h
		$HitRay.cast_to.x = -$HitRay.cast_to.x
		
		if turn_around_timer.time_left <= 0.0:
			turn_around_timer = get_tree().create_timer(1.15, false)
			if !is_yield_paused:
				yield(turn_around_timer, "timeout")
				if !has_player:
					$Sprite.flip_h = !$Sprite.flip_h
					$HitRay.cast_to.x = -$HitRay.cast_to.x
# ------------------------------------------------------------------------------

func shoot(): # FIRE A PROJECTILE 
	if !is_dead:
		if attack_timer.time_left <= 0.0:
			attack_timer = get_tree().create_timer(3.25, false)
			if !is_yield_paused:
				yield(attack_timer, "timeout")
				if has_player:
					# PLAYER IS HIDING
					if player.is_hidden:
						turn_around()
						return
						
					elif !player.is_dead:
						var projectile = ProjectilePath.instance()
						add_child(projectile)
