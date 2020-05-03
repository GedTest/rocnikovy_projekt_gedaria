extends Node

var checkpoint
var currentLevel = null
#const SAVE_PATH = "user://Level/SavedData/save.json"
const SAVE_PATH = 'res://Level/SavedData/save.json'
# ------------------------------------------------------------------------------
func SaveGame(scene):
	currentLevel = scene
	# Get data to save from nodes
	var saveData = {}
	var nodesToSave = get_tree().get_nodes_in_group('persistant')
	for node in nodesToSave:
		saveData[node.get_path()] = node.Save()
	
	# Create a file to save on disk
	var saveFile = File.new()
	saveFile.open(SAVE_PATH,File.WRITE)
	
	# Write into a file
	saveFile.store_line(JSON.print(saveData))
	
	saveFile.close()
# ------------------------------------------------------------------------------
func LoadGame():
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
			if attribute != 'pos':
				node.set(attribute, data[nodePath][attribute])
			else:    # Exception for position (Vector2 is not supported by JSON)
				node.position = Vector2(data[nodePath]['pos']['x'],data[nodePath]['pos']['y'])
# ------------------------------------------------------------------------------
func GetScene():
	return get_tree().get_current_scene().filename
# ------------------------------------------------------------------------------
func set_checkpoint(posX, posY):
	checkpoint = Vector2(posX,posY)
# ------------------------------------------------------------------------------
func get_checkpoint():
	return checkpoint
# ------------------------------------------------------------------------------
func get_level():
	return currentLevel
# ------------------------------------------------------------------------------
