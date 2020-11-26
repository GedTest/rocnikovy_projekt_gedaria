extends Control

var strSaveLoadAction = "load"
var bYieldStop = true
onready var arrSaveSlots = [$CanvasLayer/SaveSlot1,$CanvasLayer/SaveSlot2,
						$CanvasLayer/SaveSlot3,$CanvasLayer/CheckpointSaveSlot]
func _ready():
	get_tree().paused = false
func _on_StartButton_pressed():
	get_tree().change_scene("res://Level/Chase/ChaseLevel.tscn")
# ------------------------------------------------------------------------------
func _on_LoadButton_pressed():
	for SaveSlot in arrSaveSlots:
		SaveSlot.visible = !SaveSlot.visible
		
		if !Save_Load.SaveSlot1[3]:
			$CanvasLayer/SaveSlot1/Label1.text = Save_Load.SaveSlot1[0]
			$CanvasLayer/SaveSlot1/Label2.text = Save_Load.SaveSlot1[1]
			$CanvasLayer/SaveSlot1/Label3.text = Save_Load.SaveSlot1[2]
		if !Save_Load.SaveSlot2[3]:
			$CanvasLayer/SaveSlot2/Label1.text = Save_Load.SaveSlot2[0]
			$CanvasLayer/SaveSlot2/Label2.text = Save_Load.SaveSlot2[1]
			$CanvasLayer/SaveSlot2/Label3.text = Save_Load.SaveSlot2[2]
		if !Save_Load.SaveSlot3[3]:
			$CanvasLayer/SaveSlot3/Label1.text = Save_Load.SaveSlot3[0]
			$CanvasLayer/SaveSlot3/Label2.text = Save_Load.SaveSlot3[1]
			$CanvasLayer/SaveSlot3/Label3.text = Save_Load.SaveSlot3[2]
# ------------------------------------------------------------------------------
func _on_QuitButton_pressed():
	get_tree().quit()
# ------------------------------------------------------------------------------



func _on_SaveSlot1_pressed():
	if !Save_Load.SaveSlot1[3]:
		Save_Load.bLoad = true
		Save_Load.fileNum = 0
		get_tree().change_scene(Save_Load.SaveSlot1[4])

func _on_SaveSlot2_pressed():
	if !Save_Load.SaveSlot2[3]:
		Save_Load.bLoad = true
		Save_Load.fileNum = 1
		get_tree().change_scene(Save_Load.SaveSlot2[4])

func _on_SaveSlot3_pressed():
	if !Save_Load.SaveSlot3[3]:
		Save_Load.bLoad = true
		Save_Load.fileNum = 2
		get_tree().change_scene(Save_Load.SaveSlot3[4])

func _on_CheckpointSaveSlot_pressed():
	Save_Load.bLoad = false
	get_tree().change_scene(Save_Load.CheckpointSaveSlot)
