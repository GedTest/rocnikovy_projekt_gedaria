extends Button



var strAction = ""
var bEmpty = true
var currentScene = null

const SAVE_PATH = 'user://ss1.json'

func _ready():
	currentScene = Save_Load.GetScene()
	$Label1.text = Save_Load.SaveSlot1[0]
	$Label2.text = Save_Load.SaveSlot1[1]
	$Label3.text = Save_Load.SaveSlot1[2]
	bEmpty = Save_Load.SaveSlot1[3]
	
func _on_SS1_pressed():
	if currentScene != "res://Level/MainMenu/MainMenu.tscn":
		strAction = get_parent().get_parent().strSaveLoadAction
		
		# LOAD GAME FROM SAVE SLOT
		if strAction == "load":
			if !bEmpty:
				Save_Load.bLoad = true
				yield(get_tree().create_timer(2.0),"timeout")
				Save_Load.LoadGame(SAVE_PATH)
		
		# SAVE GAME TO SAVE SLOT
		if strAction == "save":
			Save_Load.SaveGame(currentScene,SAVE_PATH)
			var data = Save_Load.get_Load_Data()
			
			# SHOW GAME DATA ON SAVE SLOT
			var level = str(Save_Load.get_level()).substr(12).split(".")
			var health = str(data.values()[1]["health"])
			var time = OS.get_datetime()
			var day = ""
			match time["weekday"]:
				0: day = "Sunday "
				1: day = "Monday "
				2: day = "Tuesday "
				3: day = "Wednesday "
				4: day = "Thursday "
				5: day = "Friday "
				6: day = "Saturday "
			
			$Label1.text = "Vladimir's health:" + health 
			$Label2.text = "Level: " + level[0]
			$Label3.text = str(time["hour"])+":"+str(time["minute"])+":"+str(time["second"]) +" "+ day + str(time["day"])+"."+str(time["month"])+"."+str(time["year"])
			bEmpty = false
		
		Save_Load.SaveSlot1[0] = $Label1.text
		Save_Load.SaveSlot1[1] = $Label2.text
		Save_Load.SaveSlot1[2] = $Label3.text
		Save_Load.SaveSlot1[3] = bEmpty
		Save_Load.SaveSlot1[4] = Save_Load.get_level()
