extends Node2D


var player = null

var is_cutscene_playing = false
var is_enemies_moving = false

var guardian_pos = 0
var patroller_pos = 0


func _ready():
	$Guardian/Hand.hide()
	$Guardian/Enemy.hide()
	$Patroller/Hand.hide()
	$Patroller/Enemy.hide()
# ------------------------------------------------------------------------------

func _process(delta):
	if is_cutscene_playing:
		$Guardian.move()
		$Patroller.move($Patroller.from, $Patroller.to)
		
		if $Guardian.position.x < guardian_pos:
			self.set_animation(true, $Guardian)
			$Guardian/Sprite.hide()
		if $Patroller.position.x < patroller_pos:
			self.set_animation(true, $Patroller)
			$Patroller/Sprite2.hide()
			
			if self.player:
				self.player = null
				yield(get_tree().create_timer(0.5), "timeout")
				self.is_cutscene_playing = false
				Global.level_root().find_node("BOSS_EARL").is_cutscene_finished = true
				Global.level_root().find_node("BOSS_EARL").state_machine.travel("RUN")
			
	if is_enemies_moving:
		$Guardian.move()
		$Patroller.move($Patroller.from, $Patroller.to)
# ------------------------------------------------------------------------------

func set_animation(condition, enemy):
	enemy.is_moving = not condition
	enemy.find_node("Hand").visible = condition
	enemy.find_node("Enemy").visible = condition
# ------------------------------------------------------------------------------

func play(guardian_pos=200, patroller_pos=100, player=null):
	self.guardian_pos = guardian_pos
	$Guardian.starting_position = guardian_pos
	$Guardian/Sprite.flip_h = true
	self.patroller_pos = patroller_pos
	$Patroller.from = patroller_pos
	$Patroller.to = patroller_pos
	
	if player:
		self.player = player
		self.player.is_moving = false
		self.player.velocity = Vector2.ZERO
		var animation_player = self.player.find_node("AnimationTree")
		var arg = "parameters/IDLE/blend_position"
		animation_player.set(arg, self.player.attack_direction)
		self.player.state_machine.travel("IDLE")
	elif not player and not is_cutscene_playing:
		$Father.show()
		$Tween.interpolate_property($Father, "position", Vector2(2250, 1595), \
					Vector2(1125, 1595), 2.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		
	is_cutscene_playing = true
# ------------------------------------------------------------------------------

func run_away(pos, direction):
	$Guardian.starting_position = pos
	self.set_animation(false, $Guardian)
	$Guardian/Sprite.show()
	$Guardian.direction = direction
	$Guardian/Sprite.flip_h = false if direction == 1 else true
	
	$Patroller.velocity.x = $Patroller.speed*direction
	self.set_animation(false, $Patroller)
	$Patroller/Sprite2.show()
	$Patroller.direction = direction
	$Patroller.to = pos
	$Patroller.from = pos
	
	yield(get_tree().create_timer(0.5), "timeout")
	$Guardian.state_machine.travel("RUN")
	$Patroller.state_machine.travel("RUN")
	
	self.is_enemies_moving = true
