extends Button


export (String, 
		"čeština",
		"english",
		"polskie",
		"deutsche",
		"slovenčina",
		"français",
		"italiano",
		"русский",
		"español",
		"português"
) var language


func _ready():
	self.text = language
# ------------------------------------------------------------------------------

func _on_lang_btn_pressed():
#	var settings = {
#		"lang":{"pref_lang":language}
#	}
	Global.prefered_language = language
#	Settings.save(settings)
	var root = Global.level_root()
	if "arr_texts" in root:
		Languages.translate(root.arr_texts, language)
	else:
		var pause_menu = root.find_node("CanvasLayer")
		Languages.translate(pause_menu.arr_texts, language)
