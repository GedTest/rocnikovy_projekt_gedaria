extends Enemy


const PROJECTILE_PATH = preload("res://Enemy/E-Test/Projectile.tscn")
const AIMING_BERNARD = "Bernadr.png"

export(bool) var can_shoot_in_sector = false

var turn_around_timer = null
var has_spotted_player = false
var aim_direction = 1

onready var rotation_objects = [$HitRay, $left_hand, $right_hand, $musket]


func _ready():
	can_attack = true
	cooldown_timer = get_tree().create_timer(0.0, false)
	turn_around_timer = get_tree().create_timer(0.0, false)
	if can_shoot_in_sector:
		$SpotArea/CollisionPolygon2D.disabled = false
		for obj in rotation_objects:
			obj.show()
		$Sprite.hide()
#		$Sprite.texture = load(AIMING_BERNARD)
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
		
		direction = 1 if $HitRay.cast_to.x > 0 else -1
		
		if can_shoot_in_sector:
			self.aim()
			
		if has_player and can_attack:
			self.shoot()
			
		if has_player and has_spotted_player:
			for obj in rotation_objects:
				obj.rotation_degrees = find_angle_between(player.position, self.position)

# ------------------------------------------------------------------------------

func turn_around(): # LOOK BACK AND FORTH
	if !is_dead:
		$Sprite.flip_h = !$Sprite.flip_h
		$HitRay.cast_to.x = -$HitRay.cast_to.x
		
		if turn_around_timer.time_left <= 0.0:
			turn_around_timer = get_tree().create_timer(1.3, false)
			if !is_yield_paused:
				yield(turn_around_timer, "timeout")
				$Sprite.flip_h = !$Sprite.flip_h
				$HitRay.cast_to.x = -$HitRay.cast_to.x
# ------------------------------------------------------------------------------

func shoot(): # FIRE A PROJECTILE 
	if !is_dead:
		can_attack = false
		$AnimationTree.set("parameters/ATTACK/blend_position", direction)
		state_machine.travel("ATTACK")
		if attack_timer.time_left <= 0.0:
			attack_timer = get_tree().create_timer(1.15, false)
			if !is_yield_paused:
				yield(attack_timer, "timeout")
				if has_player:
					# PLAYER IS HIDING
					if player.is_hidden:
						turn_around()
						can_attack = true
						return
						
					if !player.is_dead:
						var projectile = PROJECTILE_PATH.instance()
						if can_shoot_in_sector:
							self.find_coordinations()
						projectile.position = $BulletSpawnPoint.position
						add_child(projectile)
						$AudioStreamPlayer2D.play()
						
		if cooldown_timer.time_left <= 0.0:
			cooldown_timer = get_tree().create_timer(3.65, false)
			if !is_yield_paused:
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
	if $HitRay.rotation_degrees < 57:
		aim_direction = -0.4
	if $HitRay.rotation_degrees > 123:
		aim_direction = 0.4
	
	for obj in rotation_objects:
		obj.rotation_degrees -= (aim_direction/2)
# ------------------------------------------------------------------------------

func find_coordinations():
	var V = Vector2.RIGHT
	var A = $PointA.global_position
	var B = $HitRay.global_position
	var U = Vector2(player.global_position.x - B.x, player.global_position.y - B.y)
	
	var t = ((U.y*A.x) - (U.y*B.x) - (A.y*U.x) + (B.y*U.x)) / ((V.y*U.x) - (U.y*V.x))
	var x = A.x + V.x*t
	var y = A.y + V.y*t
	
	
	$BulletSpawnPoint.global_position = Vector2(x, y)
