extends Enemy


const ProjectilePath = preload("res://Enemy/E-Test/Projectile.tscn")

export(bool) var can_shoot_in_sector = false

var turn_around_timer = null
var has_spotted_player = false
var aim_direction = 1


func _ready():
	turn_around_timer = get_tree().create_timer(0.0, false)
	if can_shoot_in_sector:
		$SpotArea/CollisionPolygon2D.disabled = false
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _process(delta):
	if !is_dead:
		# LOOK AROUND FOR PLAYER
		if turn_around_timer.time_left <= 0.0 and !has_player and !can_shoot_in_sector:
			turn_around_timer = get_tree().create_timer(5.0, false)
			if !is_yield_paused:
				yield(turn_around_timer, "timeout")
				self.turn_around()
		
		direction = 1 if $Sprite.flip_h else -1
		
		if can_shoot_in_sector:
			self.aim()
			
		if has_player:
			self.shoot()
			
			if has_spotted_player:
				$HitRay.rotation_degrees = find_angle_between(player.position, self.position)
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
			attack_timer = get_tree().create_timer(3.0, false)
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
# ------------------------------------------------------------------------------

func find_angle_between(player, enemy):
	var direction_vector = Vector2(player.x - enemy.x, player.y - enemy.y)
	var normal_vector = Vector2.RIGHT
	
	var angle = rad2deg(normal_vector.angle_to(direction_vector))
	
	direction = direction_vector.normalized()
	return angle
# ------------------------------------------------------------------------------

func _on_SpotArea_body_entered(body):
	if body.get_collision_layer_bit(1):
		has_spotted_player = true
# ------------------------------------------------------------------------------

func _on_SpotArea_body_exited(body):
	if body.get_collision_layer_bit(1):
		has_spotted_player = false
# ------------------------------------------------------------------------------

func aim():
	if $HitRay.rotation_degrees < 57:
		aim_direction = -0.4
	if $HitRay.rotation_degrees > 123:
		aim_direction = 0.4
	
	$HitRay.rotation_degrees -= (aim_direction/2)
