extends Sprite

export(String, "throwing",
				"raking_out_leaves_horizontal",
				"raking_out_leaves_vertical",
				"hiding",
				"heavy_attack",
				"shooting",
				"raking",
				"wind",
				"pause",
				"interaction"
)var text

var small_pos_y = -108
var small_size_y = 198
var big_pos_y = -125
var big_size_y = 290

func _on_Area_body_entered(body):
	if body.get_collision_layer_bit(1):
		var new_text = "[center]" + Languages.languages[Global.prefered_language][text] + "[/center]\n"
		
		if (len(new_text)-39) / 19 < 5:
			$TextSprite/RichTextLabel.rect_size.y = small_size_y
			$TextSprite/RichTextLabel.rect_position.y = small_pos_y
			$TextSprite/RichTextLabel.get_font("normal_font").size = 41
		else:
			$TextSprite/RichTextLabel.rect_size.y = big_size_y
			$TextSprite/RichTextLabel.rect_position.y = big_pos_y
			$TextSprite/RichTextLabel.get_font("normal_font").size = 33
		
		$TextSprite/RichTextLabel.bbcode_text = new_text
		$TextSprite.show()
# ------------------------------------------------------------------------------

func _on_Area_body_exited(body):
	if body.get_collision_layer_bit(1):
		$TextSprite.hide()
