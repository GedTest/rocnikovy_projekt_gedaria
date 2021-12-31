class_name Level
extends Node2D


const FOREST_MUSIC = preload("res://gedaria_theme1wav.wav")
const CAVE_MUSIC = preload("res://cave_theme.wav")
const CAVE_LEVELS = [
	"res://Level/CaveEntrance/Cave entrance.tscn",
	"res://Level/CaveEntrance/Lil cave.tscn",
	"res://Level/CultInCave/Mine shaft.tscn",
]

var is_done_once = true
var is_yield_paused = false

var acorn_counter = 0
var unique_leaves_counter = 0

var arr_enemies = []
var arr_killed_enemies = []

onready var arr_patrollers = []
onready var arr_guardians = []
onready var arr_shooters = []
onready var leaf_holders = $LeafHolders.get_children()


func _ready():
#	Global.set_player_position_at_start($Vladimir, $Level_start)
	if Global.level_root().filename != "res://Level/InTheWood/In the wood.tscn":
		Global.is_first_entrance(self.filename)
	

	get_tree().set_pause(true)
	Global.can_be_paused = true
	SaveLoad.load_map()
	Fullscreen.hide_elements()
	self.play_level_title_effect()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
# ------------------------------------------------------------------------------

func play_level_title_effect():
	var label = $CanvasLayer/LevelLabel
	
	var level = Global.level_root().filename.split('/')[4].split('.')[0]
	label.text = Languages.languages[Global.prefered_language][level]
	
	$CanvasLayer/LevelTween2.interpolate_property(label, "modulate", \
	Color(1, 1, 1, 0), Color(1, 1, 1, 1), 2.0, Tween.TRANS_QUAD, Tween.EASE_OUT, 1.0)
	$CanvasLayer/LevelTween.interpolate_property(label, "rect_position", \
	label.rect_position, Vector2(label.rect_position.x, label.rect_position.y-80),\
							3.0, Tween.TRANS_QUAD, Tween.EASE_OUT, 1.25)
	$CanvasLayer/LevelTween2.start()
	$CanvasLayer/LevelTween.start()
	
	yield(get_tree().create_timer(6.0), "timeout")
	$CanvasLayer/LevelTween2.interpolate_property(label, "modulate", \
	Color(1, 1, 1, 1), Color(1, 1, 1, 0), 2.0, Tween.TRANS_QUAD, Tween.EASE_IN, 1.0)
	$CanvasLayer/LevelTween2.start()
# ------------------------------------------------------------------------------

func _on_LoadingTimer_timeout(): # Yield() doesn't work in ready() so an autostart timer is needed
	SaveLoad.update_current_data()
	yield(get_tree().create_timer(0.1), "timeout")

	get_tree().set_pause(false)
	Global.is_yield_paused = false
	if Global.level_root().filename != "res://Level/InTheWood/In the wood.tscn":
		if Global.first_entrance:
			self.set_vladimirs_skills()
	$CanvasLayer/UserInterface.load_ui_icons()
	if Global.level_root().filename in CAVE_LEVELS:
		AudioManager.play_music(CAVE_MUSIC)
	else:
		AudioManager.play_music(FOREST_MUSIC)

	for leaf_holder in leaf_holders:
		if is_instance_valid(leaf_holder):
			if leaf_holder.has_leaf:
				leaf_holder.show_leaf()

	arr_enemies = arr_guardians + arr_patrollers + arr_shooters
# ------------------------------------------------------------------------------

# warning-ignore:unused_argument
func _process(delta):
	Global.level_root().find_node("Sign").played_time += delta/2
	
	for i in arr_patrollers:
		i.move(i.from, i.to)

	for i in arr_guardians:
		i.move()
		if i.from != 0 or i.to != 0:
			i.move_in_range(i.from, i.to)
	
	for enemy in arr_enemies:
		if enemy.is_dead and not enemy in arr_killed_enemies:
			arr_killed_enemies.append(enemy)
# ------------------------------------------------------------------------------

func _on_KillZone_body_entered(body, sec=0.7): # Kills player if he fall into
	if body.get_collision_layer_bit(1):
		body.is_dead = true
		yield(get_tree().create_timer(sec), "timeout")
		body.die()
# ------------------------------------------------------------------------------

func set_vladimirs_skills():
	$Vladimir.heavy_attack_counter += $Vladimir.heavy_attack_increment
	$Vladimir.has_learned_attack = true
	$Vladimir.has_learned_heavy_attack = true
	$Vladimir.has_learned_blocking = true
	$Vladimir.has_learned_raking = true
	
	if Global.arr_levels.find(Global.level_root().filename) > 4:
		$Vladimir.has_learned_leaf_blower = true
