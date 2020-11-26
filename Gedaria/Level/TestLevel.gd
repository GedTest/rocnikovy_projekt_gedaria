extends Node2D

var checkpoint = null
var currentScene = null
var bOnce = true
var bYieldStop = false
var pebblePath = preload("res://Vladimir/PebbleOnGround.tscn")

onready var arrPatrollers = [$Patroller,$Patroller2,$Patroller3,$Patroller4,
							$Patroller5,$Patroller6,$Patroller7,$Patroller9,
							$Patroller10]
onready var arrGuardians = [$Guardian,$Guardian2,$Guardian3,$Guardian4,
							$Guardian5]

onready var arrSaveSlots = [$CanvasLayer/SaveSlot1,$CanvasLayer/SaveSlot2,
							$CanvasLayer/SaveSlot3,$CanvasLayer/Close]
onready var arrButtons = [$CanvasLayer/SaveButton,$CanvasLayer/LoadButton,
						$CanvasLayer/RestartButton,$CanvasLayer/MainMenuButton,]
const arrSAVE_PATH = ['user://ss1.json','user://ss2.json','user://ss3.json','user://checkpoint.json']
var strSaveLoadAction = ""

func _ready():
	get_tree().set_pause(true)
	SaveLoad.load_map()
	#if Save_Load.bLoad:
	#	_on_LOAD()
	#if Save_Load.checkpoint && !Save_Load.bLoad:
	#	$Vladimir.position = Save_Load.checkpoint
	
	$Vladimir/Camera.current = true
	#######$CanvasLayer/UserInterface.LoadUiIcons()
	#currentScene = Save_Load.GetScene()
# ------------------------------------------------------------------------------
func _on_LoadingTimer_timeout(): # Yield() doesn't work in ready() so an autostart timer is needed
	SaveLoad.update_current_data()
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().set_pause(false)
	Global.bYieldStop = false
# ------------------------------------------------------------------------------
# warning-ignore:unused_argument
func _process(delta):
	for i in arrPatrollers:
		i.Move(i.from,i.to)
		
	for i in arrGuardians:
		i.Move()

	if $Patroller8.bFocused:
		$Patroller8.Move($Patroller8.from,$Patroller8.to)
		
	if $PilesOfLeaves/PileOfLeaves1.bComplete:
		$Wind.position = Vector2(35500,7000)
	
# ------------------------------------------------------------------------------
func _on_SaveButton_pressed(): # Show save slots and save game
	strSaveLoadAction = "save"
	for SaveSlot in arrSaveSlots:
		SaveSlot.show()
	for button in arrButtons:
		button.hide()
	$CanvasLayer/SaveButton.release_focus()
# ------------------------------------------------------------------------------
func _on_LoadButton_pressed(): # Show save slots and load game
	strSaveLoadAction = "load"
	for SaveSlot in arrSaveSlots:
		SaveSlot.show()
		$CanvasLayer/CheckpointSaveSlot.show()
	for button in arrButtons:
		button.hide()
	$CanvasLayer/LoadButton.release_focus()
# ------------------------------------------------------------------------------
func _on_RestartButton_pressed(): # Restart the level from beginning
	bYieldStop = true
	$CanvasLayer/UserInterface.bYieldStop = bYieldStop
	get_tree().paused = true
	yield(get_tree().create_timer(5.0),"timeout")
	Save_Load.set_checkpoint($Checkpoint2.position.x,$Checkpoint2.position.y)
	get_tree().change_scene(currentScene)
# ------------------------------------------------------------------------------
func _on_MainMenuButton_pressed(): # Go to Main Menu
	bYieldStop = true
	$CanvasLayer/UserInterface.bYieldStop = bYieldStop
	get_tree().paused = true
	yield(get_tree().create_timer(5.0),"timeout")
	get_tree().change_scene("res://Level/MainMenu/MainMenu.tscn")
# ------------------------------------------------------------------------------
func _on_Close_pressed(): # Show / hide buttons
	for SaveSlot in arrSaveSlots:
		SaveSlot.hide()
		$CanvasLayer/CheckpointSaveSlot.hide()
		$CanvasLayer/Close.hide()
	for button in arrButtons:
		button.show()
	$CanvasLayer/Close.release_focus()
# ------------------------------------------------------------------------------
func _on_KillZone_body_entered(body): # Kills player if he fall into
	if body.get_collision_layer_bit(1):
		yield(get_tree().create_timer(0.5),"timeout")
		$Vladimir.Death()
# ------------------------------------------------------------------------------
#func _on_LOAD(): # Load previous saved game if it was any
#	# Check if the file exists otherwise return
#	var SAVE_PATH = arrSAVE_PATH[Save_Load.fileNum]
#	var saveFile = File.new()
#	
#	if !saveFile.file_exists(SAVE_PATH):
#		print('Error 1 the file %s doesn´t exist.',saveFile)
#		return
#	
#	# Open a file and convert JSON into an object
#	saveFile.open(SAVE_PATH, File.READ)
#	
#	var data = {}
#	data = JSON.parse(saveFile.get_line()).result
#	#print(data)
#	
#	# Set saved values
#	for nodePath in data.keys():
#		var node
#		node = get_node(nodePath)
#		
#		for attribute in data[nodePath]:
#			if attribute != 'pos':
#				node.set(attribute, data[nodePath][attribute])
#			else:    # Exception for position (Vector2 is not supported by JSON)
#				node.position = Vector2(data[nodePath]['pos']['x'],data[nodePath]['pos']['y'])
#	# # # #
#	#
#	#
#	#Save_Load.SaveGame(currentScene,SAVE_PATH)
#	#
#	#
#	# # # #

func _on_SlingshotButton_pressed():
	$Vladimir.bHasSlingshot = !$Vladimir.bHasSlingshot
	$CanvasLayer/SlingshotButton.release_focus()
	
func AddPebble(oldPebblePosition):
	var newPebble = pebblePath.instance()
	$Pebbles.call_deferred("add_child",newPebble)
	newPebble.position = oldPebblePosition
