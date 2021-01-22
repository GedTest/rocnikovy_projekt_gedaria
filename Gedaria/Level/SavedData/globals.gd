extends Node


var blue_berries = 0
var last_map = ""
var arr_levels = [
	"res://Level/TestLevel.tscn","res://Level/DarkForest/DarkForest.tscn",
	"ahoj_level"
]
var language = {
	"czech":{
		"throwing":"Za pomocí kamenů nyní můžeš házet na včelí úly, tím vyprovokuješ včely., Zmáčkni tlačítko 'Q' a zamiř na úl, potom stiskni levé tlačítko myši",
		"raking_out_leaves":"Vladimír může svými hráběmi odhrnovat listí. Podrž tlačítko 'Shift'",
		"hiding":"V křoví je Vladimír skryt zrakům jeho nepřátel. Zmáčkni 'S' pro schování se do keře",
		"heavy_attack":"Štít protivníků se dá prolomit silným útokem. Silný útok působí obyčejným protivníkům dvojnásobné poškození. Silný útok je omezený nabitím unikatních listů, která jsou schované v levelu.",
		"attack":"Pro útok zmáčkni levé tlačítko myši",
		"interaction":"Zmáčkni 'E' pro interakci",
		"movement":"Pro pohyb použij tlačítka 'A' / 'D'",
		"blocking":"Podržením 'Mezerníku' ve srpávný čas zablokuješ nepřítelův útok",
		"shooting":"Nyní můžeš střílet kameny prakem na nepřátele, čímž jim způsobíš poškození.",
		"raking":"Vladimír může svými hráběmi hrabat listí na hromady. S něktrými je pak možno i hybát.",
		"wind":"Pomocí větru může Vladimír dostat listy na vyvýšená místa.",
		"jumping":"Pro skok zmáčkni 'W'",
		"crawling":"Pro skrčení se zmáčkni 'S'",
		"boss_warden_quote":"„Rozluč se svoji rodinou spratku, vidíš je naposled!“",
		"letter":" „Našli jste již ty hrábě, pro které jsem vás vyslal? Musíme je urychleně najít, za každou cenu. Potřebuji víc duší, pro můj magický experiment -  „metamorfózu“, přiveďte co nejvíce vesničanů, pokračujte v pátrání po mocné duši. Nadešel čas odvést Vladimírova otce. Dostavte se do mé pevnosti, ihned jakmile jej zadržíte. Podejte hlášení kapitánu _____.“",
		},
	"english":{}
}

var next_level_id = arr_levels.find(last_map) - 1
var prev_level_id = arr_levels.find(last_map) + 1
# Vladimir's variables

var is_pausable = false
var is_yield_paused = false


func level_root():
	for root in get_tree().get_nodes_in_group("root"):
		return root
# ------------------------------------------------------------------------------

func get_position_2D(ID):
	print("ID: ",ID)
	for x in get_tree().get_nodes_in_group("pos"):
		if x.name == ID:
			return x
# ------------------------------------------------------------------------------

func delete_actor(relate):
	SaveLoad.current_data.erase(str([level_root().filename, relate.name]))
	relate.queue_free()
# ------------------------------------------------------------------------------

func vladimir_data():
	return "["+arr_levels[prev_level_id]+", Vladimir]"
# ------------------------------------------------------------------------------

func get_next_level():
	return arr_levels[next_level_id]
# ------------------------------------------------------------------------------

func vladimir_has_previous_data():
	return SaveLoad.slots["slot_4"].has(vladimir_data())
# ------------------------------------------------------------------------------

func stop_enemy_timers():
	is_yield_paused = true
	if "arr_enemies" in level_root():
		
		for enemy in level_root().arr_enemies:
			if !enemy.is_dead:
				enemy.turn_around_timer.time_left = 0.0
				if "cooldown_roll_timer" in enemy:
					enemy.cooldown_roll_timer.time_left = 0.0
# ------------------------------------------------------------------------------

#func Persistant():
#	return level_root().get_node("Persistant")
#func teleport_actor(relate, map, pos_ID):
#	if SaveLoad.current_data.has([level_root().filename, relate.name]):
#		var old = (SaveLoad.current_data[[level_root().filename, relate.name]]).duplicate()
#		SaveLoad.current_data[[map, relate.name]] = old
#		SaveLoad.current_data[[map, relate.name]]["next_pos_ID"] = pos_ID
#		SaveLoad.current_data.erase([level_root().filename, relate.name])
#		relate.queue_free()
# ------------------------------------------------------------------------------
#
#func player():
#	for x in get_tree().get_nodes_in_group("player"):
#		return x
# ------------------------------------------------------------------------------

#func change_level(map, pos_ID):
#	teleport_actor(player(), map, pos_ID)
#	yield(get_tree().create_timer(0.1), "timeout")
#	get_tree().change_scene(map)
