extends Sprite

var arrKeys = ["Left Arrow","Right Arrow","Up Arrow","Down Arrow"]
var button = "Up Arrow"
var timer = null
var counter = 0

func _ready():
	timer = get_tree().create_timer(0.0)

func _process(delta):
	$Label.text = "Press button " + button
		
	if Input.is_action_just_pressed(button) && get_parent().bCanInteract:
		randomize()
		match button:
			"Left Arrow": position.x -= 12
			"Right Arrow": position.x += 12
			"Up Arrow": position.y -= 16
		
		counter += 1
		get_parent().find_node("Shake").start(10,1.5,0.1,Vector2(0.8,0.8),Vector2(0,100))
		$Label.hide()
		button = arrKeys[rand_range(0,3)]
		if timer.time_left <= 0.0 && counter < 7:
			timer = get_tree().create_timer(0.25)
			yield(timer, "timeout")
			$Label.show()
			
	if counter == 7:
		get_parent().bPickedUp = true
		get_parent().find_node("InteractTutorial").hide()
		get_parent().bIsRake = false
