extends Node2D


const SegmentPath = preload("res://Rope_test/Segment.tscn")

export (int) var segments = 10

onready var arr_segments = [$HeaderSegment,]


var segment_gravity = Vector2(0, 150)
var segment_scalar = 10


func _ready():
	for number in range(segments):
		var segment = SegmentPath.instance()
		
		self.add_child(segment)
		arr_segments.append(segment)
#-------------------------------------------------------------------------------

func _process(delta):
	for segment in arr_segments:
		var index = arr_segments.find(segment)
		if index == 0:
			continue
		
		var previous_node_pos = arr_segments[index-1].pos_ex
		segment.velocity = (
			previous_node_pos - segment.global_position
				)*segment_scalar + segment_gravity
				
		segment.pos_ex = segment.global_position
		
		#segment.move_and_collide(segment.velocity)
		segment.move_and_slide(segment.velocity,Vector2(0,0),false,4,PI,false)
		

	for segment in arr_segments:
		if segment.name == "HeaderSegment":
			continue
		var index = arr_segments.find(segment)
		var distance = (segment.position - arr_segments[index-1].position)
		var direction = distance.normalized()

		if abs(distance.x) > 50:
			segment.position.y -= (distance.x * direction.x)
			
		if abs(distance.x) < 50:
			segment.position.y += (distance.x * direction.x)
#		elif abs(distance.y) > 100:
#			segment.position.x -= (distance.y * direction.y)
#
#		print(segment.name," je vzdálený: ",distance," od ",arr_segments[index-1].name," směrem: ",direction)
#-------------------------------------------------------------------------------

func _physics_process(delta):
	$Line2D.clear_points()
	
	for segment in arr_segments:
		$Line2D.add_point(segment.position)
