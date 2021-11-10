class_name Enemy, "res://Enemy/BOSS_Warden/BOSS_Warden.png"
extends KinematicBody2D
"""
Base enemy class
"""



var GRAVITY = Vector2(0, 98)
const WARNING_ICON = 12
const HIDDEN_ICON = 13

var direction = 1
var velocity = Vector2(0, 0)

export(int) var FoV = 250
export(int) var health
export(int) var speed
export(int) var from
export(int) var to
export(int) var damage
export(int) var jump_strength = 1500
export(bool) var is_jumping = false

var distance = 0
var hit_in_row = 0
var death_anim_time = 3.0
var death_frame = 0
var hit_anim_time = 0.75
var things_to_save = {}

var is_dead = false
var has_player = false
var can_attack = false
var is_attacking = false
var is_heavy_attacked = false
var is_blocking = false
var is_timeout = false
var is_yield_paused = false
var is_focused = false
var is_moving = true
var can_warn = false
var is_hitted = false

var player = null
var attack_timer = null
var hit_timer = null
var cooldown_timer = null
var turn_around_timer = null
var sfx_timer = null
var state_machine = null


func _ready():
	$HitRay.cast_to.x = FoV
	cooldown_timer = get_tree().create_timer(0.0, false)
	attack_timer = get_tree().create_timer(0.0, false)
	hit_timer = get_tree().create_timer(0.0, false)
	turn_around_timer = get_tree().create_timer(0.0, false)
	sfx_timer = get_tree().create_timer(0.0, false)
	state_machine = $AnimationTree.get("parameters/playback")
	
	self.reset_icon()
# ------------------------------------------------------------------------------

func _physics_process(delta):
	is_yield_paused = Global.is_yield_paused
	velocity.y += GRAVITY.y
	if not is_dead:
	# IS IT ALIVE ?
		if health <= 0 or is_dead:
			self.die()
		
		if $HitRay.is_colliding() and $HitRay.get_collider().name == "Vladimir":
			# PLAYER IS SPOTTED
			player = $HitRay.get_collider()
			has_player = true
			if can_warn:
				$Icon.frame = WARNING_ICON
				$Icon.show()
				$Tween.start()
				can_warn = false
		else:
			player = null
			has_player = false
			
		if has_player and not player.is_dead:
			distance = abs(position.x - player.position.x)
			# DISTANCE IS USED TO CALC VARIOUS BEHAVIOUR
	
		velocity = move_and_slide(velocity)
	
	elif is_dead and not $CollisionShape2D.disabled:
		# WHEN RELOAD DEAD ENEMY DISALBE HIS COLLISION
		$CollisionShape2D.disabled = true
# ------------------------------------------------------------------------------

func die():
	health = 0
	$HitRay.enabled = false
	can_attack = false
	is_dead = true
	self.z_index -= 1
	
	state_machine.travel('DEATH')
	
	if not is_yield_paused:
		yield(get_tree().create_timer(death_anim_time), "timeout")
		$Weapon/CollisionShape2D.disabled = true
# ------------------------------------------------------------------------------

func save():
	# SAVE VARIABLES IN DICTIONARY
	things_to_save.is_dead = self.is_dead
	things_to_save.health = self.health
	things_to_save.speed = self.speed
	things_to_save.damage = self.damage
	things_to_save.FoV = self.FoV
	things_to_save.direction = self.direction
	things_to_save.from = self.from
	things_to_save.to = self.to
	
	return things_to_save
# ------------------------------------------------------------------------------

func attack(attack_time, cooldown_time):
	if not is_dead and not is_attacking:
		is_moving = false
		$AnimationTree.set("parameters/ATTACK/blend_position", direction)
		state_machine.travel('ATTACK')
		
		if attack_timer.time_left <= 0.0:
			attack_timer = get_tree().create_timer(cooldown_time, false)
			if not is_yield_paused:
				yield(attack_timer, "timeout")
				if has_player:
					if not player.is_dead and can_attack:
						is_attacking = true
						if not player.is_blocking:
							player.hit(damage)
						
				if attack_timer.time_left <= 0.0:
					attack_timer = get_tree().create_timer(attack_time, false)
					if not is_yield_paused:
						yield(attack_timer, "timeout")
						is_attacking = false
						is_moving = true
# ------------------------------------------------------------------------------

func hit(dmg):
	is_moving = false
	is_hitted = true
	health -= dmg if not is_heavy_attacked else dmg * 2
	if not (health - dmg) < 0 and dmg > 0:
		state_machine.travel('HIT')
	if hit_timer.time_left <= 0.0:
		hit_timer = get_tree().create_timer(hit_anim_time)
		if not is_yield_paused:
			yield(hit_timer, "timeout")
			is_moving = true
			is_hitted = false
# ------------------------------------------------------------------------------

func _on_Weapon_body_entered(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		can_attack = true
# ------------------------------------------------------------------------------

func _on_Weapon_body_exited(body):
	if body.get_collision_layer_bit(1):
		can_attack = false
# ------------------------------------------------------------------------------

func _on_WallDetection_body_entered(body):
	# JUMP UP WHEN HE IS NEAR WALL
	if body.get_collision_layer_bit(19) and is_jumping:
		velocity.y -= jump_strength
# ------------------------------------------------------------------------------

func jump_back(var obj=self, var distance = 100, var time = 0.3, dir=-direction):
	# KNOCKBACK obj IN distance AND direction
	$AdvancedTween.play(time, obj.position.x, obj.position.x + (distance*dir))
# ------------------------------------------------------------------------------

func _on_AdvancedTween_advance_tween(sat):
	self.position.x = sat
# ------------------------------------------------------------------------------

func _on_Tween_tween_completed(object, key):
	# HIDE ICON AFTER EFFECT
	can_warn = true
	$Icon.hide()
# ------------------------------------------------------------------------------

func reset_icon():
	if find_node("Tween"):
		$Tween.stop_all()
		$Tween.reset_all()
		if find_node("Icon"):
			$Icon.scale = Vector2(0.9, 0.9)
			$Icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
		
		$Tween.interpolate_property($Icon, "scale", Vector2(0.6, 0.6),\
								Vector2(0.9, 0.9), 0.5,\
								Tween.TRANS_QUAD, Tween.EASE_OUT)
		$Tween.interpolate_property($Icon, "modulate", Color(1,1,1,1),\
								Color(1.0,1.0,1.0,0.0), 1.0,\
								Tween.TRANS_QUAD, Tween.EASE_OUT, 0.35)
