extends Area2D


export (Vector2) var impulse = Vector2(1250, -1600)
export (bool) var is_leaf_blower = false
export (bool) var can_blow_player = false

var has_enemy = false
var leaf = null

var angle = 0
var decreasing_impulse = 0


func _ready():
	if can_blow_player:
		$CollisionPolygon2D.disabled = false
		$CollisionPolygon2D2.disabled = false
		$CollisionPolygon2D3.disabled = false
		$CollisionPolygon2D4.disabled = false
		$Particles2D.lifetime = 3
		$Particles2D.speed_scale = 3
# ------------------------------------------------------------------------------

func _physics_process(delta):
	if is_leaf_blower:
		if has_enemy and decreasing_impulse < 100:
			decreasing_impulse += 1.2
		if leaf:
			angle = rad2deg(leaf.global_position.angle_to_point(self.get_parent().global_position))
# ------------------------------------------------------------------------------

func _on_Wind_body_entered(body):
	if body is LeafHolder:
		return
	
	if body.get_collision_layer_bit(3) or (body.get_collision_layer_bit(10) and is_leaf_blower):
		# don't blow away leaves that have to fill quickleaves
		if "QuickLeaves" in body.get_parent().name:
			return
		leaf = body
		body.linear_velocity = Vector2.ZERO
		body.linear_damp = 0.25
		impulse *= 3 if body is PileOfLeaves else 1
		if is_leaf_blower:
			impulse.y = -1600 if angle < 20 or angle > 160 else 1600
		body.apply_central_impulse(impulse)
	
	if body.get_collision_layer_bit(2) and is_leaf_blower:
		if not can_blow_player and "BOSS_ONIHRO" in body.name:
			if body.can_be_hitted_again:
				body.state_machine.travel("HIT")
				body.blowing_time += 0.016
				if body.blowing_time >= 1.5:
					body.is_hitted_by_wind = true
		
		if "Hand" in body.name:
			return 
		
		if not "BOSS_ONIHRO" in body.name:
			has_enemy = true
			var root = Global.level_root()
			var direction = root.find_node("Vladimir").position.direction_to(body.position)
			direction = 1 if direction.x > 0 else -1
			var force = -5 if body.name == "BOSS_EARL" else 100
			if force-decreasing_impulse <= 0:
				has_enemy = false
				return 
			body.jump_back(body, force-decreasing_impulse, 0.3, direction)
		
	
	if can_blow_player and body.get_collision_layer_bit(1):
		body.jump_strength *= impulse.y
		body.modify_speed *= impulse.x
# ------------------------------------------------------------------------------

func disable_wind():
	for child in self.get_children():
		if "CollisionShape2D" in child.name:
			$CollisionShape2D.disabled = true
			self.hide()
# ------------------------------------------------------------------------------

func _on_WindBlowerWind_body_exited(body):
	if can_blow_player and body.get_collision_layer_bit(1):
		body.jump_strength = 1800
		body.modify_speed /= impulse.x
	if body.get_collision_layer_bit(3):
		leaf = null
