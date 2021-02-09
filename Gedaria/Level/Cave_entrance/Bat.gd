extends Enemy


export (int) var height = 0


func _process(delta):
	if !is_dead:
		velocity.y = -GRAVITY.y
		
		if $HitRay.is_colliding():
			fly_down()
				
		elif int(self.position.y) >= height:
			fly_back_up()
# ------------------------------------------------------------------------------

func move(var from, var to): # MOVE
	if !is_dead:
	# MOVE FROM 'A' TO 'B'
		if !has_player:
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
				if !can_attack:
					direction = 1
					$Sprite.flip_h = true
					$HitRay.cast_to.x = FoV
			
			# MOVE TOWARDS PLAYER (LEFT)
			elif player.position.x >= position.x-FoV and player.position.x < position.x:
				if !can_attack:
					direction = -1
					$Sprite.flip_h = false
					$HitRay.cast_to.x = -FoV
			
		velocity.x = speed * direction * int(is_moving)
# ------------------------------------------------------------------------------

func fly_back_up():
	velocity.y -= 200
# ------------------------------------------------------------------------------

func fly_down():
	var vertical_distance = abs(self.position.y - player.position.y)
	if vertical_distance > 0:
		velocity.y += vertical_distance*2
# ------------------------------------------------------------------------------

func attack(player):
#	$AnimationTree.set("parameters/ATTACK/blend_position",direction)
#	state_machine.travel('ATTACK')
	
	if has_player:
		$HitRay.enabled = false
		if !player.is_dead:
			if !player.is_blocking:
				player.hit(damage)
				print("Vladimir's health: ", player.health)

	if attack_timer.time_left <= 0.0:
		attack_timer = get_tree().create_timer(0.75, false)
		if !is_yield_paused:
			yield(attack_timer, "timeout")
			$HitRay.enabled = true
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		self.attack(body)
	
	if body.get_collision_layer_bit(7):
		self.hit(3)
