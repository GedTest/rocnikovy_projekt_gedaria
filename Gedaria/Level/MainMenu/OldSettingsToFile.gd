extends Node


const SAVE_PATH = "res://cfg.cfg"

var config_file = ConfigFile.new()
#var settings = {
#	"ahoj": {
#		"a":"1",
#		"b":"2",
#		"c":"3"
#		}
#}
var local_settings = {}


#func _ready():
#	save()
#	load_settings()
# ------------------------------------------------------------------------------

func save(settings):
	for section in settings.keys():
		for key in settings[section].keys():
			config_file.set_value(section, key, settings[section][key])
	
	local_settings = settings
	config_file.save(SAVE_PATH)
# ------------------------------------------------------------------------------
	
func load_settings():
	var error = config_file.load(SAVE_PATH)
	if error != OK:
		print("Error loading the settings. Error code: ",error)
		return []

	var values = []
	for section in local_settings.keys():
		for key in local_settings[section].keys():
			pass
			#Global.prefered_language = local_settings[section]["pref_lang"]


#			var val = local_settings[section][key]
#			values.append(config_file.get_value(section, key, val))
#			print("%s: %s" % [key, val])
#	return values
