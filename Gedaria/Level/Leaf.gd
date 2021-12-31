extends RigidBody2D


export(String, "res://UI/list_buk.png",
	"res://UI/list_břečťan.png", "res://UI/list_dub.png",
	"res://UI/list_ginko_biloba.png", "res://UI/list_kopřiva.png",
	"res://UI/list_lipa.png", "res://UI/list_olše.png",
	"res://UI/list_ořech.png", "res://UI/list_javor_červený.png", 
	"res://UI/list_javor_velkolistý.png"
) var texture = "res://UI/list_olše.png"

const COLORS = [
	Color("f9b34a"),Color("ad372a"),
	Color("bc6633"),Color("a15f32"),
	Color("008d36"),Color("006742"),
	Color("006742"),
]


func _ready():
	$Sprite.texture = load(texture)
	
	var level_index = Global.arr_levels.find(Global.level_root().filename)
	var reminder = 7 if level_index < 2 or level_index > 4 else 4
	$Sprite.modulate = COLORS[randi()%reminder]
