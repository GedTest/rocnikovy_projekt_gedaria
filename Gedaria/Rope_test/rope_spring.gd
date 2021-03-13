extends Node2D


const SegmentPath = preload("res://Rope_test/RopeSegment.tscn")

export (int) var segments = 10

onready var arr_segments = [$RopeHead,]


var segment_gravity = Vector2(0, 100)
var segment_scalar = 100000


func _ready():
	for number in range(segments):
		var segment = SegmentPath.instance()
		var spring = DampedSpringJoint2D.new()
		self.add_child(spring)
		self.add_child(segment)
		segment.position.x = arr_segments.back().position.x + 5
		
		spring.node_a = arr_segments.back().get_path()
		spring.node_b = segment.get_path()
		spring.length = 0
		spring.rest_length = 0
		spring.stiffness = 32
		
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
		
		#segment.move_and_slide(segment.velocity,Vector2(0,0),false,4,PI,false)
		

	for segment in arr_segments:
		if segment.name == "HeaderSegment":
			continue
		var index = arr_segments.find(segment)
		var distance = (segment.position - arr_segments[index-1].position)
		var direction = distance.normalized()
		
		#if abs(distance.x) > 50 and abs(distance.x) < 51:
		#	segment.position.y += (distance.x * direction.x)
#-------------------------------------------------------------------------------

func _physics_process(delta):
	$Line2D.clear_points()
	
	for segment in arr_segments:
		$Line2D.add_point(segment.position)
