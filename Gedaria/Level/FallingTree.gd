extends StaticBody2D


func fall():
	$AnimationPlayer.play("fall")
	var level = Global.level_root()
	
	level.find_node("Patroller3").to = 6900
	level.find_node("Patroller4").to = 6900
