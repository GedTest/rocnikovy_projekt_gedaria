class_name Mushroom, "res://Level/Mushroom+.png"
extends Sprite


export (String) var hp = "plus"

var damage = 1


func _on_Area2D_body_entered(body):
	match hp:
		"plus":
			if body.get_collision_layer_bit(1) and body.health < body.max_health:
				get_parent().get_parent().find_node("UserInterface").\
				update_health(1, hp, body.health, body.max_health)
				body.health += 1
				SaveLoad.delete_actor(self)
				
		"minus":
			if body.get_collision_layer_bit(1) and body.health > 0:
				body.hit(damage)
				SaveLoad.delete_actor(self)
# ------------------------------------------------------------------------------
