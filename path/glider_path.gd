extends Path3D
# Generates a Hilbert SFC, then selects a random portion to create a curve for.
# en.wikipedia.org/wiki/Hilbert_curve#Representation_as_Lindenmayer_system


# MEMBERS ######################################################################
var DRAW_HILBERT = true
var HEIGHT = 15.0

# VIRTUALS #####################################################################
func _ready() -> void:
	var hilbert_curve : Curve2D = create_hilbert_curve2d(3)
	print(hilbert_curve.get_point_count())
	#if DRAW_HILBERT: 
	#for _point in hilbert_curve: print(_point)



# METHODS ######################################################################
func create_hilbert_curve2d(order : int) -> Curve2D:
	# Define Hilbert curve L-System 
	var _alphabet = {"productions":["A","B"], "constants":["F","+","-"]} # V
	var _axiom = "A" # w
	var _productions = {"A":"+BF−AFA−FB+", "B":"−AF+BFB+FA−"} # P
	
	# Create L-System Components
	var _curve = Curve2D.new()
	var _l_system_str : String = _axiom
	
	# Iterate to make specific order Hilbert L-System string
	for _current_iteration in order:
		print("Iteration " + str(order) + ", start: " + _l_system_str)
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
		print("Iteration " + str(order) + ", finished: " + _l_system_str)
	
	# Use string-encoded L-System string to guide the progress of a curve3D
	var _path_direction = Vector2(1,0) # Vector starts in +X direction
	# First point...
	_curve.add_point(Vector2.ZERO, Vector2.ZERO, _path_direction)
	# ...create the rest.
	for _symbol in _l_system_str:
		match _symbol:
			"A": break
			"B": break
			"F": set_next_lsystem_point(_path_direction, _curve)
			"+": _path_direction.rotated(-PI/2) # anti-clockwise 90deg
			"-": _path_direction.rotated(PI/2)	# clockwise 90deg
	
	return _curve

# Inserts a point on a curve
func set_next_lsystem_point(direction:Vector2, curve:Curve2D) -> void:
	var _point_count = curve.get_point_count()
	var _point_pos = curve.get_point_position(_point_count - 1) + direction
	
	
	curve.add_point(_point_pos, -curve.get_point_out(_point_count-1), direction)
	return

func draw_line(position_1 : Vector3, position_2 : Vector3) -> void:
	pass
