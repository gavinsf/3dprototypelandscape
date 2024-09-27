extends Node3D
# Creates verticies to form a landscape


var MESH_SCALE : float = 20.0

func _ready() -> void:
	# generate noise
	var noise = FastNoiseLite.new()
	var image = noise.get_image(512, 512)
	
	# startmesh generation
	var land = MeshInstance3D.new()
	var st = SurfaceTool.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count : Array[int] = [0]
	var texture = ImageTexture.create_from_image(image)
	
	var material = StandardMaterial3D.new()
	material.albedo_texture = texture
	
	for i in range(64):
		for j in range(64):
			var noiseVal1 = noise.get_noise_2d(i, j) * MESH_SCALE
			var noiseVal2 = noise.get_noise_2d(i+1, j) * MESH_SCALE
			var noiseVal3 = noise.get_noise_2d(i+1, j+1) * MESH_SCALE
			var noiseVal4 = noise.get_noise_2d(i, j+1) * MESH_SCALE
			
			_quad(st, Vector3(i,0,j), count, noiseVal1, noiseVal2, noiseVal3, noiseVal4)
			_quad(st, Vector3(i,0,j), count, noiseVal1, noiseVal2, noiseVal3, noiseVal4)
	
	st.generate_normals() # normals point perpendicular up from each face
	var mesh = st.commit() # arranges mesh data structures into arrays for us
	land.mesh = mesh
	land.material_override = material
	add_child(land)
	pass 

func _quad(
	st : SurfaceTool,
	pt: Vector3,
	count: Array[int],
	noiseVal1,
	noiseVal2,
	noiseVal3,
	noiseVal4,
	):
	st.set_uv( Vector2(0, 0) )
	st.add_vertex(pt + Vector3(0, noiseVal1, 0) ) # vertex 0
	count[0] += 1
	st.set_uv( Vector2(1, 0) )
	st.add_vertex(pt +  Vector3(1, noiseVal2, 0) ) # vertex 1
	count[0] += 1
	st.set_uv( Vector2(1, 1) )
	st.add_vertex(pt +  Vector3(1, noiseVal3, 1) ) # vertex 2
	count[0] += 1
	st.set_uv( Vector2(0, 1) )
	st.add_vertex(pt +  Vector3(0, noiseVal4, 1) ) # vertex 3
	count[0] += 1
	
	st.add_index(count[0] - 4) # make the first triangle
	st.add_index(count[0] - 3)
	st.add_index(count[0] - 2)
	
	st.add_index(count[0] - 4) # make the second triangle
	st.add_index(count[0] - 2)
	st.add_index(count[0] - 1)
