extends Sprite
class_name Mushroom, "res://Level/Mushroom+.png"

export (String) var HP = "plus"

func _on_Area2D_body_entered(body):
	match HP:
		"plus":
			if body.get_collision_layer_bit(1) && body.health < 12:
				get_parent().get_parent().find_node("UserInterface").UpdateHealth(1,HP,body.health)
				body.health += 1
				SaveLoad.delete_actor(self)
				
		"minus":
			if body.get_collision_layer_bit(1) && body.health > 0:
				get_parent().get_parent().find_node("UserInterface").UpdateHealth(1,HP,body.health)
				body.health -= 1
				SaveLoad.delete_actor(self)
