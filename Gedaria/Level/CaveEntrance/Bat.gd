extends Enemy


const BAT_SFX = preload("res://sfx/bat_chirpping.wav")

export (int) var height = 0

var is_on_ground = false


func _process(delta):
	if not is_dead:
		velocity.y = -GRAVITY.y
		
		if $HitRay.is_colliding():
			self.fly_down()
				
		elif int(self.position.y) >= height:
			self.fly_back_up()
# ------------------------------------------------------------------------------

func move(var from, var to): # MOVE
	if not is_dead:
	# MOVE FROM 'A' TO 'B'
		if not has_player:
			if position.x > to:
				direction = -1
				$Sprite.flip_h = false
				$HitRay.cast_to.x = -FoV
				
			elif position.x < from:
				direction = 1
				$Sprite.flip_h = true
				$HitRay.cast_to.x = FoV
				
	# FOLLOW PLAYER OR NOT
		if has_player:
			# PLAYER IS HIDING
			if player.is_hidden:
				$HitRay.enabled = false
				has_player = false
				player = null
				return
			
			# MOVE TOWARDS PLAYER (RIGHT)
			if player.position.x <= position.x+FoV and player.position.x > position.x:
				if not can_attack:
					direction = 1
					$Sprite.flip_h = true
					$HitRay.cast_to.x = FoV
					$Particles2D.rotation_degrees = 197
			
			# MOVE TOWARDS PLAYER (LEFT)
			elif player.position.x >= position.x-FoV and player.position.x < position.x:
				if not can_attack:
					direction = -1
					$Sprite.flip_h = false
					$HitRay.cast_to.x = -FoV
					$Particles2D.rotation_degrees = -15
			
		velocity.x = speed * direction * int(is_moving)
		
	elif is_dead and not is_on_ground:
		$CollisionShape2D.disabled = false
		self.velocity = Vector2.ZERO
		self.velocity = GRAVITY*3
		self.move_and_slide(velocity)
# ------------------------------------------------------------------------------

func fly_back_up():
	state_machine.travel('FLY')
	velocity.y -= 200
# ------------------------------------------------------------------------------

func fly_down():
	AudioManager.play_sfx(BAT_SFX, 1, 0, -15)
	state_machine.travel('ATTACK')
		
	var vertical_distance = abs(self.position.y - player.position.y)
	if vertical_distance > 0:
		velocity.y += vertical_distance*2
# ------------------------------------------------------------------------------

func bite(player):
	if has_player:
		$HitRay.enabled = false
		if not player.is_dead:
			if not player.is_blocking:
				player.hit(damage)

	if attack_timer.time_left <= 0.0:
		attack_timer = get_tree().create_timer(0.75, false)
		if not is_yield_paused:
			yield(attack_timer, "timeout")
			$HitRay.enabled = true
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		self.bite(body)
	
	if body.get_collision_layer_bit(7):
		self.hit(3)
# ------------------------------------------------------------------------------

func _on_GroundArea_body_entered(body):
	if body.get_collision_layer_bit(0):
		yield(get_tree().create_timer(1.0, false), "timeout")
		is_on_ground = true
