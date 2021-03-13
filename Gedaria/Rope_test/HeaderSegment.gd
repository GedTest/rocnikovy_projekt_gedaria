extends KinematicBody2D

var mouse_pos = Vector2()
var velocity = Vector2()
var gravity = Vector2(0, 0)
var pos_ex = Vector2()
var offset = Vector2(26, 64)

var vladimir = null


func _ready():
	vladimir = get_parent().get_parent()
	mouse_pos = position
# ------------------------------------------------------------------------------

func _process(delta):
	if vladimir.name == "Vladimir":
		if vladimir.velocity.x != 0:#Input.is_action_pressed("attack"):
			mouse_pos = vladimir.position + offset #get_global_mouse_position()
			pos_ex = global_position
			velocity = (mouse_pos - global_position).normalized() * 750
			
		else:
			velocity = Vector2(0, 0)
			
		velocity += gravity
		
		if global_position == offset: #get_global_mouse_position():
			velocity.y = 0
			
		move_and_slide(velocity)
	
