class_name Enemy, "res://Enemy/sprites/_IDLE/_IDLE_000.png"
extends KinematicBody2D


const GRAVITY = Vector2(0, 98)

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

var distance
var movement_speed
var hit_in_row = 0
var death_anim_time = 3.0
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

var player = null
var attack_timer = null
var hit_timer = null
var cooldown_timer = null
var state_machine = null


func _ready():
	$CollisionShape2D.disabled = false
	$HitRay.cast_to.x = FoV
	movement_speed = speed
	cooldown_timer = get_tree().create_timer(0.0, false)
	attack_timer = get_tree().create_timer(0.0, false)
	hit_timer = get_tree().create_timer(0.0, false)
	state_machine = $AnimationTree.get("parameters/playback")
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _physics_process(delta):
	is_yield_paused = Global.is_yield_paused
	if !is_dead:
	# GRAVITY
		velocity.y += GRAVITY.y
	# IS IT ALIVE ?
		if health <= 0 or is_dead:
			die()
		
	# does he see the player ?
		if $HitRay.is_colliding() and $HitRay.get_collider().name == "Vladimir":
			player = $HitRay.get_collider()
			has_player = true
		else:
			player = null
			has_player = false
			
		if has_player and !player.is_dead:
			distance = abs(position.x - player.position.x)
	
		velocity = move_and_slide(velocity)
# ------------------------------------------------------------------------------

func die(): # CHARACTER DIES
	health = 0
	can_attack = false
	is_dead = true
	velocity = GRAVITY
	state_machine.travel('DEATH') # play dying animation
	if !is_yield_paused:
		yield(get_tree().create_timer(death_anim_time), "timeout")
		$CollisionShape2D.disabled = true
		$Weapon/CollisionShape2D.disabled = true
		$AnimationTree.active = false
# ------------------------------------------------------------------------------

func save(): # SAVE VARIABLES IN DICTIONARY
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

func hit(dmg):
	speed = 0
	health -= dmg if !is_heavy_attacked else dmg * 2
	if health > 0:
		state_machine.travel('HIT')
		if hit_timer.time_left <= 0.0:
			hit_timer = get_tree().create_timer(hit_anim_time)
			if !is_yield_paused:
				yield(hit_timer, "timeout")
				speed = movement_speed
# ------------------------------------------------------------------------------

func _on_Weapon_body_entered(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		can_attack = true
# ------------------------------------------------------------------------------

func _on_Weapon_body_exited(body):
	# collision_layer_bit 1 = Player
	if body.get_collision_layer_bit(1):
		can_attack = false
# ------------------------------------------------------------------------------

func _on_WallDetection_body_entered(body):
	if body.get_collision_layer_bit(0) and is_jumping:
		velocity.y -= jump_strength
