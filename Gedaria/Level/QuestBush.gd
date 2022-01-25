extends AnimatedSprite


var can_interact = false

func _ready():
	if Global.level_root().filename == "res://Level/InTheWood/In the wood.tscn":
		$Icon.show()
	elif Global.level_root().filename == "res://Level/MerchantSquirrel.tscn":
		if Global.blue_berries == 5:
			self.play("happy")
# ------------------------------------------------------------------------------

func _process(delta):
	if can_interact and Input.is_action_just_pressed("interact"):
		$Icon.hide()
		var animation = "happy" if Global.blue_berries == 5 else "sad"
		var level = Global.level_root()
		self.play(animation)
		
		
		if level.filename == "res://Level/InTheWood/In the wood.tscn":
			$Label.text = Languages.languages[Global.prefered_language]["bush_quest"]
		elif Global.blue_berries == 5:
			$Label.text = Languages.languages[Global.prefered_language]["bush_thanks"]
			level.find_node("UserInterface").find_node("Blueberries").hide()
			level.find_node("UserInterface").find_node("BlueberryCounter").hide()
			
		$Label.show()
		
		yield(get_tree().create_timer(5.0, false), "timeout")
		$Label.hide()
# ------------------------------------------------------------------------------

func _on_Area2D_body_entered(body):
	if body.get_collision_layer_bit(1):
		can_interact = true
		Global.level_root().find_node("Tutorial").wrap_intreaction_text($Icon/Label)
		$Label.get_font("font").size = 50
		$Icon.show()
# ------------------------------------------------------------------------------

func _on_Area2D_body_exited(body):
	if body.get_collision_layer_bit(1):
		can_interact = false
		$Icon.hide()
