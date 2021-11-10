extends "res://Level/SavedData/globals.gd"

# ------------------------------------------------------------------------------
#         A D V A N C E     S A V E     A N D     L O A D     S Y S T E M
# ------------------------------------------------------------------------------
var paths = [
	"user://Saves/slot_1.json", "user://Saves/slot_2.json",
	"user://Saves/slot_3.json", "user://Saves/slot_4.json",
	"user://config.json"
]
var last_saved_slot = 0

var slots = {
	"slot_1":{},
	"slot_2":{},
	"slot_3":{},
	"slot_4":{},
}

# UPDATED REGULARLY
var current_data = {
}

# UPDATED AT MAP'S _READY
var map_data = {
}

var visited_maps = []

func reset_data():
	current_data = {}
	map_data = {}
	visited_maps = []
# ------------------------------------------------------------------------------

func restart_level():
	get_tree().change_scene(get_tree().get_current_scene().filename)
# ------------------------------------------------------------------------------

func update_current_data():
	if level_root() != null:

		for node in get_tree().get_nodes_in_group("persistant"):
			var node_data = [] # array

			# save fixed variables (in func save_node())
			node_data = save_node(node).duplicate()

			# save custom variables
			if node.has_method("save"):
				var dict = node.save()
				for y in dict:
					node_data[y] = dict[y]
			
			# stich save data together
			current_data[str([level_root().get_filename(), node.name])] = node_data
		current_data["last_map"] = level_root().get_filename()
		current_data["visited_maps"] = visited_maps.duplicate()

		current_data["date"] = {
			"second":OS.get_time()["second"],
			"minute":OS.get_time()["minute"],
			"hour":OS.get_time()["hour"],
			"day":OS.get_date()["day"],
			"month":OS.get_date()["month"],
			"year":OS.get_date()["year"],
		}

		current_data["last_saved_slot"] = last_saved_slot
		
		# SAVING GLOBAL VALUES
		current_data["globals"] = {
			"blue_berries":Global.blue_berries,
			"leaves_in_cave_counter":Global.leaves_in_cave_counter,
			"has_key":Global.has_key,
		}
# ------------------------------------------------------------------------------

func update_map_data():
	if level_root() != null:
		for node in get_tree().get_nodes_in_group("persistant"):
			var node_data = []

			# save fixed variables (in func save_node())
			node_data = save_node(node).duplicate()

			# save custom variables
			if node.has_method("save"):
				var dict = node.save()
				for y in dict:
					node_data[y] = dict[y]

			# stich save data together
			map_data[[level_root().get_filename(), node.name]] = node_data
# ------------------------------------------------------------------------------
func load_map():
	#	data structure ---- [[map_filename, node_name], node]
	update_map_data()

	var persist_nodes = get_tree().get_nodes_in_group("persistant")

	var keys_in_map = []
	for node in persist_nodes:
		keys_in_map.append([[level_root().filename, node.name], node])
	
	if visited_maps.has(level_root().filename):
		# DELETE OBJECTS
		for key in keys_in_map:
			if not(current_data.has( str(key[0]) )): # if c_d doesn't have key
				key[1].queue_free()                # free it from memory
	else:
		visited_maps.append(level_root().filename)

	# ADD OBJECTS
	for x in current_data:
		var substrArray = [""]
		if x[0] == "[":
			substrArray = x.substr(1,x.length()-2).split(", ")

			substrArray = Array(substrArray)
		
		if substrArray[0] == level_root().filename and not(map_data.has(substrArray)):
			var obj = load(current_data[x]["file"]).instance()
			obj.name = current_data[x]["name"]
			level_root().get_node(current_data[x]["parent"]).add_child(obj)

	# UPDATE OBJECTS
	yield(get_tree().create_timer(0.15), "timeout")
	for node in get_tree().get_nodes_in_group("persistant"):
		update_node(node)
# ------------------------------------------------------------------------------
func update_node(node):
	if current_data.has( str([level_root().filename, node.name]) ):
		var data = current_data[ str([level_root().filename, node.name] )]
		
		if not(node is Control):
			node.global_position = Vector2(data["pos"]["x"], data["pos"]["y"])
		
		for x in data:
			if x == "scale":
				node.scale = Vector2(data["scale"][0], data["scale"][1])
			else:
				node.set(x, data[x])
# ------------------------------------------------------------------------------
# IMPORTANTnot THIS IS WHERE YOU DECLARE VALUES TO BE SAVEDnot
func save_node(node):
	# general saving
	var all = {}

	if node is Node2D:
		all.parent = node.get_parent().get_path()
		all.file = node.get_filename()
		all.name = node.get_name()
		all.groups = node.get_groups()
		all.pos = {"x":node.get_global_position().x, "y":node.get_global_position().y}
		all.rotation_degrees = node.get_rotation_degrees()
		all.scale = [node.get_scale().x, node.get_scale().y]
		all.visible = node.visible

	if node is RigidBody2D:
		node.set_collision_layer_bit(3,node.get_collision_layer_bit(3))
		node.set_collision_mask_bit(3,node.get_collision_mask_bit(3))
		all.mode = node.mode
		all.mass = node.mass
		all.weight = node.weight
		all.gravity_scale = node.gravity_scale
		all.linear_velocity = node.linear_velocity
		all.linear_damp = node.linear_damp
		all.angular_velocity = node.angular_velocity
		all.angular_damp = node.angular_damp
		all.physics_material_override = node.physics_material_override
			
	if node is Area2D:
		all.pos = {"x":node.get_global_position().x, "y":node.get_global_position().y}
	
	if node is StaticBody2D:
		node.set_collision_layer_bit(3,node.get_collision_layer_bit(3))
		node.set_collision_mask_bit(3,node.get_collision_mask_bit(3))
	
	if node is Sprite:
		all.texture = node.texture
	return all
# ------------------------------------------------------------------------------
func save_to_slot(slot_name):
	update_current_data()
	if slots.has(slot_name):
		slots[slot_name] = current_data.duplicate()
		Global.last_map = slots[slot_name]["last_map"]
	else:
		print('Error 1: Saveslot ',slot_name,' doesn´t exist.')
# ------------------------------------------------------------------------------
func load_from_slot(slot_name):
	current_data = slots[slot_name].duplicate()
	visited_maps = slots[slot_name]["visited_maps"].duplicate()
	last_saved_slot = slots[slot_name]["last_saved_slot"]
	
	Global.blue_berries = slots[slot_name]["globals"]["blue_berries"]
	Global.leaves_in_cave_counter = slots[slot_name]["globals"]["leaves_in_cave_counter"]
	Global.has_key = slots[slot_name]["globals"]["has_key"]
	
	is_yield_paused = true
	
	yield(get_tree().create_timer(5.0), "timeout")
	get_tree().change_scene(slots[slot_name]["last_map"])
# ------------------------------------------------------------------------------

func save_to_file(slot):
	save_to_slot("slot_"+str(slot))

	yield(get_tree().create_timer(0.25), "timeout")
	var save_game = File.new()

	save_game.open(paths[slot-1], File.WRITE)

	save_game.store_line(to_json(current_data.duplicate()))

	save_game.close()
# ------------------------------------------------------------------------------

func save_config():
	var save_game = File.new()
	save_game.open_encrypted_with_pass(paths[4], File.WRITE, "16v04Gedaria")
	
	var settings = {
		"MasterVolume":AudioManager.get_volume("Master"),
		"MusicVolume":AudioManager.get_volume("Music"),
		"SFXVolume":AudioManager.get_volume("SFX"),
		"MSAA":get_viewport().msaa,
		"FPS":Engine.target_fps,
		"VSync":OS.vsync_enabled,
		"Language":Global.prefered_language,
		"key_mapping":Global.current_key_mapping
	}
		
	save_game.store_string(JSON.print(settings))
	save_game.close()
# ------------------------------------------------------------------------------

func load_config():
	var load_game = File.new()
	if load_game.file_exists(paths[4]):
		load_game.open_encrypted_with_pass(paths[4], File.READ, "16v04Gedaria")
	
		var setting_dict = JSON.parse(load_game.get_as_text()).result
		if not setting_dict:
			setting_dict = Global.DEFAULT_SETTINGS
		for key in setting_dict.keys():
			match key:
				"FPS":Engine.target_fps = setting_dict[key]
				"MasterVolume":AudioManager.set_volume("Master", setting_dict[key])
				"MusicVolume":AudioManager.set_volume("Music", setting_dict[key])
				"SFXVolume":AudioManager.set_volume("SFX", setting_dict[key])
				"MSAA":get_viewport().msaa = setting_dict[key]
				"VSync":OS.vsync_enabled = setting_dict[key]
				"Language":Global.prefered_language = setting_dict[key]
		
		# if there is problem with key mapping load default key mapping
		if setting_dict["key_mapping"].empty():
			setting_dict = Global.DEFAULT_SETTINGS
			
		# create InputEventKey objects from their scancode
		var loaded_key_mapping = []
		for scancode in setting_dict["key_mapping"]:
			loaded_key_mapping.append(KeyBinding.create_input_from_scancode(scancode))
		
		# assign new InputEventKey objects to current key map
		var index = 0
		for action in KeyBinding.ACTIONS:
			KeyBinding._change_key(loaded_key_mapping[index], action)
			index += 1
# ------------------------------------------------------------------------------

func load_from_file(slot):
	Global.stop_enemy_timers()
	var save_game = File.new()
	
	if not save_game.file_exists(paths[slot-1]):
		print("File ",paths[slot-1]," doesn't exist.")
		return
	
	save_game.open(paths[slot-1], save_game.READ)
	var text = save_game.get_as_text()     # text == file.json
	
	var data = parse_json(text)
	yield(get_tree().create_timer(0.05), "timeout")
	slots["slot_"+str(slot)] = data

	save_game.close()

	yield(get_tree().create_timer(0.05), "timeout")

	load_from_slot("slot_"+str(slot))
