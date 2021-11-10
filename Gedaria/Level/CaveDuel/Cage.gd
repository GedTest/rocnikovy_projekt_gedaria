extends Node2D


const QUICKLEAVES_PATH = preload("res://Level/QuickLeaves.tscn")

var ready_timer = null


func on_vladimir_escaped():
	$QuickLeaves.call_deferred("queue_free")

func prepare():
	ready_timer = get_tree().create_timer(0.0, false)
	var quickleaves = QUICKLEAVES_PATH.instance()
	quickleaves.name = "QuickLeaves"
	quickleaves.number_of_levels = 5
	quickleaves.leaf_holder_per_level = 6
	quickleaves.leaf_holder_level = 4
	quickleaves.texture = "res://UI/list_kopřiva.png"
	quickleaves.position = Vector2(-216.635, -301.761)
	var collision = quickleaves.find_node("Area2D").find_node("CollisionShape2D")
	collision.shape.set_deferred("extents", Vector2(256.418, 212.393))
	collision.position = Vector2(200, 100)
	
	
	
	if ready_timer.time_left <= 0.0:
		ready_timer = get_tree().create_timer(0.5, false)
		yield(ready_timer, "timeout")
		
		self.add_child(quickleaves)
		var boss = Global.level_root().find_node("BOSS_IN_CAVE")
		$QuickLeaves.connect("on_completed", boss, "_on_quickleaves_completed")
