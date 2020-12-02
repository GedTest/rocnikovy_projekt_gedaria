extends RigidBody2D

#var resetState = false
#var physics = true
#var savedPosition : Vector2
onready var texture = $Sprite.texture

#func _ready():
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
