extends Level


onready var arr_bats = [
	$Bat1,$Bat2,$Bat3,$Bat4,$Bat5,
	$Bat6,$Bat7,$Bat8,$Bat9,$Bat10,
	$Bat11,
]


func _on_LoadingTimer_timeout():
	._on_LoadingTimer_timeout()
	Global.update_data_from_merchant($Vladimir)
	acorn_counter = 25
	unique_leaves_counter = 1
# ------------------------------------------------------------------------------

func _process(delta):
	for bat in arr_bats:
		bat.move(bat.from, bat.to)
# ------------------------------------------------------------------------------
