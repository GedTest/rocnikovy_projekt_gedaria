extends RigidBody2D

#var resetState = false
#var physics = true
#var savedPosition : Vector2
export(String, "res://UI/list_buk.png",
	"res://UI/list_břečťan.png", "res://UI/list_dub.png",
	"res://UI/list_ginko_biloba.png", "res://UI/list_kopřiva.png",
	"res://UI/list_lipa.png", "res://UI/list_olše.png",
	"res://UI/list_ořech.png", "res://UI/list_javor_červený.png", 
	"res://UI/list_javor_velkolistý.png"
) var texture = "res://UI/list_olše.png"

func _ready():
	$Sprite.texture = load(texture)
#	if "Leaves" == get_parent().name:
#		self.add_to_group("persistant")

#func _process(delta):
#	linear_damp = 9999999999999 if linear_velocity.length() > 1000 else -1

#func save(): # SAVE POSITION AND VARIABLES IN JSON
#	savedPosition = position
#	var savedData = {
#		savedPosition = {
#			"x":savedPosition.x,
#			"y":savedPosition.y
#		}
#	}
#	return savedData
# ------------------------------------------------------------------------------
#func _integrate_forces(state):
#	if resetState:
#		var Tr = state.get_transform()
#		Tr.origin.x = savedPosition.x
#		Tr.origin.y = savedPosition.y
#		state.set_transform(Tr)
#		resetState = false
