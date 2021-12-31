extends StaticBody2D


signal on_smash_end
signal on_hand_is_at_edge

const SMASH_SFX = preload("res://sfx/onihro_attack.wav")

export (String, "Left", "Right") var side

var smash_timer = null
var warning = null
var player = null
var return_position = Vector2.ZERO
var difficulty_time = 0

var is_destroying_leaf_holders = false
var is_going_up = false
var is_clapping = false
var is_smashing_at_edges = false
var is_heavy_attacked = false


func _ready():
	if side == "Right":
		$Sprite.texture = load("res://Enemy/BOSS_ONIHRO/RightHand.png")
		$Sprite.position.x = -95
	connect("on_smash_end", self.get_parent(), "on_smash_end")
	connect("on_hand_is_at_edge", self.get_parent(), "on_hand_is_at_edge")
	smash_timer = get_tree().create_timer(0.0, false)
# ------------------------------------------------------------------------------

func smash(player_position, return_position, is_last_smash=false):
	self.return_position = return_position
	is_clapping = false
	
	# # # # # # # # # # # # # 
	# potrebuju jenom pro 1,2 punch
	var x = randi()%300
	x += 50 if side == "Left" else -50
	var dir = -1 if randi()%2 == 0 else 1
	
	# # # # # # # # # # # # # 
	# potrebuju pro 1,2 punch
	# kdyz jsou leafholders
	var y = 800
	var boss = self.get_parent()
	if is_destroying_leaf_holders:
		y = 230 + 210*boss.smash_counter
	# # # # # # # # # # # # # 
	
	
	# # # # # # # # # # # # # 
	# uprava pro punch at edges
	y += boss.position.y
	if is_smashing_at_edges:
		x = 0
		dir = 1
		y = player_position.y
	# # # # # # # # # # # # # 
	
	is_going_up = true if not is_last_smash else false
	$Tween.interpolate_property(self, "global_position", self.global_position, Vector2(player_position.x+(x*dir), y), 0.9, Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
	
	warning = Sprite.new()
	warning.modulate = Color.red
	warning.texture = load("res://icon.png")
	Global.level_root().call_deferred("add_child", warning)
	warning.global_position = Vector2(player_position.x+(x*dir), y)
# ------------------------------------------------------------------------------

func _on_Tween_tween_completed(object, key):
	AudioManager.play_sfx(SMASH_SFX, 0, 0, 5)
	if player:
		player.hit(self.get_parent().damage)
		
	var sec = 0.2 if is_smashing_at_edges else 1.2-difficulty_time
	
	if is_going_up and smash_timer.time_left <= 0.0:
		smash_timer = get_tree().create_timer(sec, false)
		yield(smash_timer, "timeout")
		is_going_up = false
		warning.call_deferred("queue_free")
		self.get_parent().is_blocking = false
		
		
		self.go_up()
		
		if not is_clapping and not is_smashing_at_edges:
			if smash_timer.time_left <= 0.0:
				smash_timer = get_tree().create_timer(0.5, false)
				yield(smash_timer, "timeout")
				emit_signal("on_smash_end", side)
			
	if is_smashing_at_edges and smash_timer.time_left <= 0.0:
		smash_timer = get_tree().create_timer(0.25, false)
		yield(smash_timer, "timeout")
		emit_signal("on_hand_is_at_edge")
# ------------------------------------------------------------------------------

func go_up():
	$Tween.interpolate_property(self, "global_position", self.global_position, self.return_position, 0.5, Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
# ------------------------------------------------------------------------------

func clap(second_hand_position):
	is_clapping = true
	
	var distance = abs(self.global_position.x-second_hand_position.x)
	var dir = ceil(self.global_position.direction_to(second_hand_position).x)
	var end_position = Vector2(self.global_position.x + (dir*((distance/2)-80)),\
							self.global_position.y)
		
	$Tween.interpolate_property(self, "global_position", self.global_position, \
								end_position, 1.0-difficulty_time,\
								Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
	is_going_up = true
# ------------------------------------------------------------------------------

# this function prepare hand's position for new mode (1,2 punch / at edges)
func transition(to_boss=true):
	var x
	var end_position
	
	if to_boss:
		x = 2720 if side == "Left" else 3720
		if self.get_parent().is_blowing:
			x = 2280 if side == "Left" else 2980
		end_position = Vector2(x, 850)
		
	else:
		x = 2360 if side == "Left" else 4000
		end_position = Vector2(x, 1600)
		
	$Tween.interpolate_property(self, "global_position", self.global_position, end_position, 0.9, Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
# ------------------------------------------------------------------------------

func hit(damage):
	var boss = self.get_parent()
	boss.is_heavy_attacked = self.is_heavy_attacked
	boss.is_hitted = true
	boss.hit(damage)
# ------------------------------------------------------------------------------

func _on_SuperArea2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		player = body
# ------------------------------------------------------------------------------

func _on_SuperArea2D_body_exited(body):
	if body.get_collision_layer_bit(1):
		player = null
