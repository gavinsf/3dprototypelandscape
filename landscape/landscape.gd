extends Node3D
# Creates verticies to form a landscape
# Displays MeshInstance


@onready var node_noise_preview = $"../UI/VBoxContainer/NoisePreview"

var MESH_SCALE : float = 20.0
var QUAD_GRID_LENGTH : int = 64
var NOISE_SIDE_LENGTH : int = 512

var estimated_color_offset : float = 0


# VIRTUALS ###################################################################
func _ready() -> void:
	
	# generate noise
	var noise = generate_random_noise()
	
	var image = noise.get_image(NOISE_SIDE_LENGTH, NOISE_SIDE_LENGTH)
	var texture = ImageTexture.create_from_image(image)
	node_noise_preview.texture = texture
	
	# landscape mesh configs
	var land = MeshInstance3D.new() # this will be one large landscape mesh.
	var st = SurfaceTool.new()
	
	#	This "count" variable is an Array[int] so Godot passes it by 
	#	_reference_ through create_quad instead of by _value_
	#	Tracks a set of vertexes in subsequent positions
	#	vvv 
	var count : Array[int] = [0] 
	
	var surface_material = StandardMaterial3D.new()
	surface_material.vertex_color_use_as_albedo = true	# these two are mutually exclusive
	#surface_material.albedo_texture = texture			# these two are mutually exclusive
	
	# start mesh generation
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(surface_material)
	
	var highest_vertex_height : float = -INF
	var lowest_vertex_height : float = INF
	var vertex_height_range : = float(MESH_SCALE) / 0.75 # what a fun hack
	
	for i in range(QUAD_GRID_LENGTH):
		for j in range(QUAD_GRID_LENGTH):
			
			var noiseVal1 = noise.get_noise_2d(i, j) * MESH_SCALE
			var noiseVal2 = noise.get_noise_2d(i+1, j) * MESH_SCALE
			var noiseVal3 = noise.get_noise_2d(i+1, j+1) * MESH_SCALE
			var noiseVal4 = noise.get_noise_2d(i, j+1) * MESH_SCALE
			
			if lowest_vertex_height > noiseVal1: lowest_vertex_height = noiseVal1
			if highest_vertex_height < noiseVal1 : highest_vertex_height = noiseVal1
			
			if vertex_height_range <= highest_vertex_height - lowest_vertex_height: vertex_height_range = highest_vertex_height - lowest_vertex_height
			
			create_quad(st, Vector3(i,0,j), count, noiseVal1, noiseVal2, noiseVal3, noiseVal4, vertex_height_range)
	
	print("Low: %s, High :%s, Range: %s" % [lowest_vertex_height, highest_vertex_height, vertex_height_range] as String)
	
	
	# commit surfaces to <MeshInstance>land
	st.generate_normals() # normals point perpendicular up from each face
	var mesh = st.commit() # arrange mesh data structures into arrays
	
	land.material_override = surface_material
	land.mesh = mesh
	
	add_child(land)


# HELPERS ###################################################################
func create_quad(
	st : SurfaceTool,
	pt: Vector3,
	count: Array[int],
	noiseVal1 : float,
	noiseVal2 : float,
	noiseVal3 : float,
	noiseVal4 : float,
	height_range : float
	):
	
	# TODO: run set_color(vertex_height) of some sort per vertex
	# if material.vertex_color_use_as_albedo = true, we can set colours here!
	#	must set to vertex noise value of 0-1)) on a per-vertex basis
	#	appears that the noise does not distribute over this range, resulting 
	#	in values well outside of 0-1
	#	testing suggests a range of (10.29,-5.6) for seed 1 (default noise seed)
	# 
	# 	must affect this range somehow, reduce it to 0-1
	var color_val_1 : float = abs(noiseVal1)/height_range
	var color_val_2 : float = abs(noiseVal2)/height_range
	var color_val_3 : float = abs(noiseVal3)/height_range
	var color_val_4 : float = abs(noiseVal4)/height_range
	
	# define vertexes
	# vertex 0
	st.set_uv( Vector2(0, 0) )
	st.set_color(Color(color_val_1,color_val_1,color_val_1,1))
	st.add_vertex(pt + Vector3(0, noiseVal1, 0) ) 
	count[0] += 1
	# vertex 1
	st.set_uv( Vector2(1, 0) )
	st.set_color(Color(color_val_2,color_val_2,color_val_2,1))
	st.add_vertex(pt +  Vector3(1, noiseVal2, 0) ) 
	count[0] += 1
	# vertex 2
	st.set_uv( Vector2(1, 1) )
	st.set_color(Color(color_val_3,color_val_3,color_val_3,1))
	st.add_vertex(pt +  Vector3(1, noiseVal3, 1) ) 
	count[0] += 1
	# vertex 3
	st.set_uv( Vector2(0, 1) )
	st.set_color(Color(color_val_4,color_val_4,color_val_4,1))
	st.add_vertex(pt +  Vector3(0, noiseVal4, 1) ) 
	count[0] += 1
	
	# construct Quad via vertexes
	st.add_index(count[0] - 4) # make the first triangle
	st.add_index(count[0] - 3)
	st.add_index(count[0] - 2)
	
	st.add_index(count[0] - 4) # make the second triangle
	st.add_index(count[0] - 2)
	st.add_index(count[0] - 1)

func generate_random_noise(seed : int = -1) -> FastNoiseLite:
	var _noise = FastNoiseLite.new()
	if seed != -1: return _noise # guard clause
	_noise.seed = randf() * 10_000_000
	
	return _noise
