extends Path3D
# Generates a Hilbert SFC, then selects a random portion to create a curve for.
# en.wikipedia.org/wiki/Hilbert_curve#Representation_as_Lindenmayer_system


# MEMBERS ######################################################################
@export var DRAW_HILBERT_CURVE = true
@export var DRAW_GLIDE_PATH = true
var HEIGHT = 15
var SCALE = 8.0
var ORDER = 5

# VIRTUALS #####################################################################
func _ready() -> void:
	var hilbert_curve : Curve2D = create_hilbert_curve2d(ORDER, SCALE)
	
	if DRAW_HILBERT_CURVE:
		draw_straight_lines_from_curve_array(hilbert_curve, HEIGHT)
	
	curve = create_curve(hilbert_curve, 6)
	
	if DRAW_GLIDE_PATH: draw_glide_path(curve)
	


# METHODS ######################################################################
func create_curve(sample_curve : Curve2D, sample_n : int) -> Curve3D:
	var _starting_index = floor(randf() * (sample_curve.point_count - sample_n))
	var _new_curve = Curve3D.new()
	
	# Add points.
	for _n in sample_n:
		var _pos : Vector2 = sample_curve.get_point_position(_starting_index + _n)
		var _point = Vector3(_pos.x, HEIGHT, _pos.y)
		_new_curve.add_point(_point, Vector3.ZERO, Vector3.ZERO)
	# Make last point = first point to knit curve together.
	_new_curve.add_point(_new_curve.get_point_position(0))
	
	# Set control points.
	for _point in _new_curve.point_count:
		var _prev_point : Vector3
		var _next_point : Vector3
		var _control : Vector3
		
		if _point == (0): _prev_point = _new_curve.get_point_position(_new_curve.point_count - 1)
		else: _prev_point = _new_curve.get_point_position(_point - 1)
		
		if _point == (_new_curve.point_count - 1): _next_point = _new_curve.get_point_position(0)
		else: _next_point = _new_curve.get_point_position(_point + 1)
		
		_control = ((_next_point) - (_prev_point)).normalized() * 5.0
		
		_new_curve.set_point_in(_point, -_control)
		_new_curve.set_point_out(_point, _control)
	
	return _new_curve

func create_hilbert_curve2d(order : int, point_scale : float) -> Curve2D:
	# Define Hilbert curve L-System 
	var _alphabet = {"productions":["A","B"], "constants":["F","+","-"]} # V
	var _axiom = "A" # w
	var _productions = {"A":"+BF-AFA-FB+", "B":"-AF+BFB+FA-"} # P
	
	# Create L-System Components
	var _curve : Array[Curve2D]= [] 
	var _l_system_str : String = _axiom
	
	_curve.push_front(Curve2D.new()) # array reference makes it passable
	
	# Iterate to make specific order Hilbert L-System string
	for _current_iteration in order:
		var _constructed_string = ""
		
		# Apply productions to current L-System iteraton.
		for _letter in _l_system_str:
			for _constant in _alphabet.constants:
				if _letter == _constant:
					_constructed_string = _constructed_string + _letter
					break;
			for _production in _alphabet.productions:
				if _letter == _production:
					_constructed_string = _constructed_string + _productions[_letter]
					break;
		
		_l_system_str = _constructed_string
	
	# Use string-encoded L-System string to guide the progress of a curve3D
	var _path_direction : Vector2 = Vector2(point_scale, 0) # Vector starts in +X direction
	
	# First point...
	_curve[0].add_point(Vector2.ZERO, Vector2.ZERO, _path_direction)
	# ...create the rest.
	for _symbol in _l_system_str:
		match _symbol:
			"A": 
				continue
			"B": 
				continue
			"F": 
				set_next_lsystem_point(_path_direction, _curve[0])
			"+": 
				_path_direction = _path_direction.rotated(PI/2) # anti-clockwise 90deg
			"-": 
				_path_direction = _path_direction.rotated(-PI/2)	# clockwise 90deg
		
	return _curve[0]

# Inserts a point on a curve
func set_next_lsystem_point(direction:Vector2, ref_curve:Curve2D) -> void:
	var _point_count = ref_curve.get_point_count()
	var _point_pos = ref_curve.get_point_position(_point_count - 1) + direction
	
	if _point_count >= 1:
		ref_curve.set_point_out(_point_count-1, direction)
	
	ref_curve.add_point(_point_pos, -direction, Vector2.ZERO)
	return

func draw_straight_lines_from_curve_array(curve_ : Curve2D, height : float) -> void:
	var _mesh = MeshInstance3D.new()
	var _surface_tool = SurfaceTool.new()
	var _material = StandardMaterial3D.new()
	_material.vertex_color_use_as_albedo = true
	var _previous_point = Vector2.ZERO
	var point_tally = -1
	
	_surface_tool.begin(Mesh.PRIMITIVE_LINES)
	var skip_flag = true
	for _point in curve_.get_baked_points():
		
		# guard clause
		if skip_flag:
			_previous_point = _point
			skip_flag = false
			continue
		
		_surface_tool.set_color(Color(1.0, 0.01, 0.01, 1.0))
		_surface_tool.add_vertex(Vector3(_previous_point.x, height, _previous_point.y))
		_surface_tool.set_color(Color(1.0, 0.01, 0.01, 1.0))
		_surface_tool.add_vertex(Vector3(_point.x, height, _point.y))
		
		point_tally += 2
		_surface_tool.add_index(point_tally - 1)
		_surface_tool.add_index(point_tally)
		
		_previous_point = _point
	
	_mesh.mesh = _surface_tool.commit()
	_mesh.material_override = _material
	
	add_child(_mesh)

func draw_glide_path(_curve):
	var _samples = 512
	var _distance = _curve.get_baked_length() / _samples
	
	var _mesh = MeshInstance3D.new()
	var _surface_tool = SurfaceTool.new()
	var _material = StandardMaterial3D.new()
	_material.vertex_color_use_as_albedo = true
	_surface_tool.begin(Mesh.PRIMITIVE_LINES)
	
	
	var _prev = _curve.sample_baked(_curve.get_baked_length())
	var point_tally = -1
	
	for _n in _samples:
		var _current = _curve.sample_baked(_n * _distance)
		
		_surface_tool.set_color(Color(1.0, 0.01, 0.01, 1.0))
		_surface_tool.add_vertex(Vector3(_prev.x, _prev.y, _prev.z))
		_surface_tool.set_color(Color(1.0, 0.01, 0.01, 1.0))
		_surface_tool.add_vertex(Vector3(_current.x, _current.y, _current.z))
		
		point_tally += 2
		_surface_tool.add_index(point_tally - 1)
		_surface_tool.add_index(point_tally)
		
		_prev = _current
	
	_mesh.mesh = _surface_tool.commit()
	_mesh.material_override = _material
	
	add_child(_mesh)
