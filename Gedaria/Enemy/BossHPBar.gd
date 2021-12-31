extends Control


func calc_health(current_health, max_health):
	$Health.value = float(current_health)/float(max_health) *100
