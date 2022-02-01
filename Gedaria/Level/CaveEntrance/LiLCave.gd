extends Level


onready var arr_bats = [
	$Bat1,$Bat2,$Bat3,$Bat4,$Bat5,
	$Bat6,$Bat7,$Bat8,$Bat9,$Bat10,
	$Bat11,
]


func _on_LoadingTimer_timeout():
	._on_LoadingTimer_timeout()
	self.update_data_from_cave_entrance()
	acorn_counter = 25
	unique_leaves_counter = 1
	
	AudioManager.stop_sfx($Vladimir.RAKING_SFX)
# ------------------------------------------------------------------------------

func _process(delta):
	for bat in arr_bats:
		bat.move(bat.from, bat.to)
# ------------------------------------------------------------------------------

func update_data_from_cave_entrance():
	if Global.first_entrance:
		var vladimir_data = "[res://Level/CaveEntrance/Cave entrance.tscn, Vladimir]"
		
		if SaveLoad.slots["slot_4"].has(vladimir_data):
			$Vladimir.set_values(SaveLoad.slots["slot_4"][vladimir_data])
