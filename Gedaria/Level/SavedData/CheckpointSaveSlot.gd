extends Button

const SAVE_PATH = 'user://checkpoint.json'
var bYieldStop = false

func _process(delta):
	bYieldStop = get_parent().get_parent().bYieldStop
# ------------------------------------------------------------------------------
func _on_CheckpointSaveSlot_pressed():
	if !bYieldStop:
		yield(get_tree().create_timer(0.5),"timeout")
		# Check if the file exists otherwise return
		var saveFile = File.new()
		if !saveFile.file_exists(SAVE_PATH):
			print('Error 1 the file %s doesn´t exist.',saveFile)
			return
		
		# Open a file and convert JSON into an object
		saveFile.open(SAVE_PATH, File.READ)
		
		var data = {}
		data = JSON.parse(saveFile.get_line()).result
		#print(data)
		
		# Set saved values
		
		for nodePath in data.keys():
			var node
			node = get_node(nodePath)
			
			for attribute in data[nodePath]:
				if attribute == 'physics':
					node.resetState = true
					
				elif attribute == 'UI':
					node.LoadUiIcons()
				
				elif attribute == 'collision':
					var collision = data[nodePath]['collision']
					node.set_collision_layer_bit(collision['num'],collision['bool'])
					node.set_collision_mask_bit(collision['num'],collision['bool'])
				
				elif attribute != 'pos':
					node.set(attribute, data[nodePath][attribute])
					
				else:    # Exception for position (Vector2 is not supported by JSON)
					node.position = Vector2(data[nodePath]['pos']['x'],data[nodePath]['pos']['y'])
