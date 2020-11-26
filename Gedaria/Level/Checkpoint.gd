extends Area2D

const SAVE_PATH = 'user://checkpoint.json'

var currentScene = null
var bEmpty = true

#func _ready():
#	currentScene = Save_Load.GetScene()

func _on_Checkpoint_body_entered(body):
	if body.get_collision_layer_bit(1):
		SaveLoad.last_saved_slot = "checkpoint"
		SaveLoad.save_to_slot("checkpoint")
#		# set checkpoint = position
#		Save_Load.set_checkpoint(position.x,position.y)
#		Save_Load.SaveGame(currentScene,SAVE_PATH)
#		Save_Load.CheckpointSaveSlot = Save_Load.get_level()
