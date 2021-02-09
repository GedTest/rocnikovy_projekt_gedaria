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
	if "arr_texts" in Global.level_root():
		Languages.translate(Global.level_root().arr_texts, language)
	
	var lang_btns = get_parent().get_parent()
	lang_btns.hide()
