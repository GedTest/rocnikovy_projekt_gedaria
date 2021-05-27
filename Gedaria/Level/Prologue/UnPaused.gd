extends Node


var is_done_once = true
var level = ""

func _ready():
	self.pause_mode = PAUSE_MODE_PROCESS

func _process(delta):
	level = Global.level_root()
	
	if Input.is_action_pressed("block") and is_done_once:
		if level.filename == "res://Level/Prologue/TutorialLevel.tscn":
			var player = level.find_node("Vladimir")
			var boss
			
			if level.is_boss_on_map:
				for node in level.get_children():
					if node.name == "Boss":
						boss = node
				
				if player.has_learned_blocking:
					is_done_once = false
					player.block()
					Fullscreen.pause()
					Fullscreen.find_node("TextEdit").show()
					boss.find_node("StaticBody2D").call_deferred("queue_free")
					level.find_node("BlockingTutorial").call_deferred("queue_free")
