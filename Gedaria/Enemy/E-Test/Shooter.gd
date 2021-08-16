class_name Shooter, "res://Enemy/E-Test/ShooterBernard.png"
extends Enemy
"""
Bernard, the musketeer
is derived from base enemy class, stationary ranged 
enemy with highest damage
"""



const PROJECTILE_PATH = preload("res://Enemy/E-Test/Projectile.tscn")
const AIMING_BERNARD = "res://Enemy/E-Test/BernardLookingDownward.png"
const NORMAL_BERNARD = "res://Enemy/E-Test/Bernadr.png"

export(bool) var can_shoot_in_sector = false

var has_spotted_player = false
var aim_direction = 1

onready var rotation_objects = [
	$HitRay, $left_hand, $right_hand, $musket
]


func _ready():
	can_attack = true
	can_warn = true
	cooldown_timer = get_tree().create_timer(0.0, false)
	death_anim_time = 1.3
	death_frame = 34
	if can_shoot_in_sector:
		$SpotArea/CollisionPolygon2D.disabled = false
		for obj in rotation_objects:
			obj.show()
	else:
		$AnimationTree.active = true
		$Sprite.vframes = 4
		$Sprite.hframes = 10
		$Sprite.texture = load(NORMAL_BERNARD)
# ------------------------------------------------------------------------------

func _process(delta):
	if not is_dead:
		if turn_around_timer.time_left <= 0.0 and not has_player and not can_shoot_in_sector:
			# LOOK AROUND FOR PLAYER
			turn_around_timer = get_tree().create_timer(5.0, false)
			if not is_yield_paused:
				yield(turn_around_timer, "timeout")
				self.turn_around()
		
		direction = 1 if $HitRay.cast_to.x > 0 else -1
		
		if can_shoot_in_sector:
			self.aim()
			
			if has_player and has_spotted_player:
				for obj in rotation_objects:
					obj.rotation_degrees = find_angle_between(player.position, self.position)
			
		if has_player and can_attack:
			self.shoot()
			
	if is_dead:
		if not is_yield_paused:
			yield(get_tree().create_timer(death_anim_time+0.3), "timeout")
			$Sprite.frame = death_frame
			$AnimationTree.active = false
# ------------------------------------------------------------------------------

func turn_around():
	if not is_dead:
		# LOOK BACK
		$Sprite.flip_h = not $Sprite.flip_h
		$HitRay.cast_to.x = -$HitRay.cast_to.x
		
		if turn_around_timer.time_left <= 0.0:
			turn_around_timer = get_tree().create_timer(1.3, false)
			if not is_yield_paused:
				yield(turn_around_timer, "timeout")
				# LOOK FORWARD
				$Sprite.flip_h = not $Sprite.flip_h
				$HitRay.cast_to.x = -$HitRay.cast_to.x
# ------------------------------------------------------------------------------

func die():
	$Sprite.texture = load(NORMAL_BERNARD)
	$Sprite.vframes = 4
	$Sprite.hframes = 10
	$AnimationTree.active = true
	for object in rotation_objects:
		object.hide()
	.die()
# ------------------------------------------------------------------------------

func shoot():
	# FIRE A PROJECTILE 
	if not is_dead:
		can_attack = false
		$AnimationTree.set("parameters/ATTACK/blend_position", direction)
		state_machine.travel("ATTACK")
		if attack_timer.time_left <= 0.0:
			attack_timer = get_tree().create_timer(1.15, false)
			if not is_yield_paused:
				yield(attack_timer, "timeout")
				if has_player:
					# PLAYER IS HIDING
					if player.is_hidden:
						self.turn_around()
						can_attack = true
						self.reset_icon()
						$Icon.frame = HIDDEN_ICON
						$Icon.show()
						return
					can_warn = true
						
					if not player.is_dead:
						# SPAWN PROJECTILE
						var projectile = PROJECTILE_PATH.instance()
						if can_shoot_in_sector:
							self.find_coordinations()
						projectile.position = $BulletSpawnPoint.position
						self.add_child(projectile)
						$AudioStreamPlayer2D.play()
						
		if cooldown_timer.time_left <= 0.0:
			cooldown_timer = get_tree().create_timer(3.65, false)
			if not is_yield_paused:
				yield(cooldown_timer, "timeout")
				can_attack = true
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
	# ROTATE OBJECTS IN SECTOR <57°, 123°>
	if $HitRay.rotation_degrees < 57:
		aim_direction = -0.4
	if $HitRay.rotation_degrees > 123:
		aim_direction = 0.4
	
	for obj in rotation_objects:
		obj.rotation_degrees -= (aim_direction/2)
# ------------------------------------------------------------------------------

func find_coordinations():
	# MOVE PROJECTILE SPAWN POINT
	# ACCORDING TO AIM DIRECTION
	var V = Vector2.RIGHT
	var A = $PointA.global_position
	var B = $HitRay.global_position
	var U = Vector2(player.global_position.x - B.x, player.global_position.y - B.y)
	
	var t = ((U.y*A.x) - (U.y*B.x) - (A.y*U.x) + (B.y*U.x)) / ((V.y*U.x) - (U.y*V.x))
	var x = A.x + V.x*t
	var y = A.y + V.y*t
	
	
	$BulletSpawnPoint.global_position = Vector2(x, y)
