extends Node2D

var checkpoint = null
var currentScene = null

func _ready():
	currentScene = Save_Load.GetScene()
	checkpoint = Save_Load.get_checkpoint()
	
	# if Player already reached checkpoint and load the game again get him to
	# checkpoint
	if checkpoint:
		$Vladimir.position = checkpoint
# ------------------------------------------------------------------------------
# warning-ignore:unused_argument
func _process(delta):
	$Enemy.Move($Enemy.from, $Enemy.to, $Enemy.position)
	$Enemy2.Move($Enemy2.from, $Enemy2.to, $Enemy2.position)
	$Enemy3.Move($Enemy3.from, $Enemy3.to, $Enemy3.position)
	$Enemy4.Move($Enemy4.from, $Enemy4.to, $Enemy4.position)
# ------------------------------------------------------------------------------
# warning-ignore:unused_argument
func _on_Checkpoint_body_entered(body):
	# set checkpoint = position
	Save_Load.set_checkpoint($Vladimir.position.x,$Vladimir.position.y)
	Save_Load.SaveGame(currentScene)
# ------------------------------------------------------------------------------
func _on_SaveButton_pressed():
	Save_Load.SaveGame(currentScene)
# ------------------------------------------------------------------------------
func _on_LoadButton_pressed():
	checkpoint = Save_Load.get_checkpoint()
	var level = Save_Load.get_level()
	
	# checkpoint is position
	if checkpoint is Vector2:
		Save_Load.LoadGame()
	
	# checkpoint is level
	if !(checkpoint is Vector2):
		get_tree().change_scene(level)
# ------------------------------------------------------------------------------
func _on_RestartButton_pressed():
	Save_Load.set_checkpoint($Checkpoint2.position.x,$Checkpoint2.position.y)
	get_tree().change_scene(currentScene)
# ------------------------------------------------------------------------------
func _on_MainMenuButton_pressed():
	get_tree().change_scene("res://Level/MainMenu/MainMenu.tscn")
