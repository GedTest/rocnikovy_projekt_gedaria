extends StaticBody2D


signal on_smash_end

export (String, "Left", "Right") var side

var smash_timer = null

var is_destroying_leaf_holders = false
var is_going_up = false
var is_clapping = false


func _ready():
	connect("on_smash_end", self.get_parent(), "on_smash_end")
	smash_timer = get_tree().create_timer(0.0, false)
# ------------------------------------------------------------------------------

func smash(player_x_position, is_last_smash=false):
	is_clapping = false
	
	var x = randi()%300
	x += 50 if side == "Left" else -50
	var dir = -1 if randi()%2 == 0 else 1
	
	var y = 800
	var boss = self.get_parent()
	if is_destroying_leaf_holders:
		y = 210 + 210*boss.smash_counter
	
	is_going_up = true if not is_last_smash else false
	$Tween.interpolate_property(self, "global_position", self.global_position, Vector2(player_x_position+(x*dir), boss.position.y+y), 1.25, Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
# ------------------------------------------------------------------------------

func _on_Tween_tween_completed(object, key):
	if is_going_up and smash_timer.time_left <= 0.0:
		smash_timer = get_tree().create_timer(1.0, false)
		yield(smash_timer, "timeout")
		is_going_up = false
		
		self.go_up()
		
		if smash_timer.time_left <= 0.0 and not is_clapping:
			smash_timer = get_tree().create_timer(0.5, false)
			yield(smash_timer, "timeout")
			emit_signal("on_smash_end", side)
# ------------------------------------------------------------------------------

func go_up():
	var x = 3390 if side == "Right" else 3050
	$Tween.interpolate_property(self, "global_position", self.global_position, Vector2(x, 837), 0.5, Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
# ------------------------------------------------------------------------------

func clap(second_hand_position):
	is_clapping = true
	
	var distance = abs(self.global_position.x-second_hand_position.x)
	if distance < 150:
		self.go_up()
	
	var dir = ceil(self.global_position.direction_to(second_hand_position).x)
	var end_position = Vector2(self.global_position.x + (dir*((distance/2)-80)), self.global_position.y)
		
	$Tween.interpolate_property(self, "global_position", self.global_position, end_position, 1.0, Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
	is_going_up = true
