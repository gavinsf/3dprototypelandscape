extends Node3D
# Creates verticies to form a landscape


@onready var node_noise_preview = $"../UI/VBoxContainer/NoisePreview"

var MESH_SCALE : float = 20.0
var QUAD_GRID_LENGTH : int = 64
var NOISE_SIDE_LENGTH : int = 512


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
	#	this way, we create vertexes in subsequent positions instead of 
	#	multiple meshes that we move afterwards.
	#	vvv 
	var count : Array[int] = [0] 
	
	var surface_material = StandardMaterial3D.new()
	surface_material.albedo_texture = texture			# these two are mutually exclusive
	
	# start mesh generation
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(surface_material)
	
	for i in range(QUAD_GRID_LENGTH):
		for j in range(QUAD_GRID_LENGTH):
			
			var noiseVal1 = noise.get_noise_2d(i, j) * MESH_SCALE
			var noiseVal2 = noise.get_noise_2d(i+1, j) * MESH_SCALE
			var noiseVal3 = noise.get_noise_2d(i+1, j+1) * MESH_SCALE
			var noiseVal4 = noise.get_noise_2d(i, j+1) * MESH_SCALE
			
			create_quad(st, Vector3(i,0,j), count, noiseVal1, noiseVal2, noiseVal3, noiseVal4)
	
	
	# commit surfaces to <MeshInstance>land
	st.generate_normals() # normals point perpendicular up from each face
	var mesh = st.commit() # arranges mesh data structures into arrays for us
	
	land.material_override = surface_material
	land.mesh = mesh
	
	add_child(land)


# HELPERS ###################################################################
func create_quad(
	st : SurfaceTool,
	pt: Vector3,
	count: Array[int],
	noiseVal1,
	noiseVal2,
	noiseVal3,
	noiseVal4,
	):
	
	# TODO: re-align albedo mapping of texture
	
	# define vertexes
	# vertex 0
	st.set_uv( Vector2(0, 0) )
	#st.set_color(Color(vertex_height))
	st.add_vertex(pt + Vector3(0, noiseVal1, 0) ) 
	count[0] += 1
	# vertex 1
	st.set_uv( Vector2(1, 0) )
	#st.set_color(Color(vertex_height))
	st.add_vertex(pt +  Vector3(1, noiseVal2, 0) ) 
	count[0] += 1
	# vertex 2
	st.set_uv( Vector2(1, 1) )
	#st.set_color(Color(vertex_height))
	st.add_vertex(pt +  Vector3(1, noiseVal3, 1) ) 
	count[0] += 1
	# vertex 3
	st.set_uv( Vector2(0, 1) )
	#st.set_color(Color(vertex_height))
	st.add_vertex(pt +  Vector3(0, noiseVal4, 1) ) 
	count[0] += 1
	
	# construct Quad via vertexes
	st.add_index(count[0] - 4) # make the first triangle
	st.add_index(count[0] - 3)
	st.add_index(count[0] - 2)
	
	st.add_index(count[0] - 4) # make the second triangle
	st.add_index(count[0] - 2)
	st.add_index(count[0] - 1)

func generate_random_noise(noise_seed : int = -1) -> FastNoiseLite:
	var _noise = FastNoiseLite.new()
	if noise_seed != -1: 
		_noise.seed = noise_seed
		return _noise # guard clause
	_noise.seed = randf() * 10_000_000
	
	return _noise
