extends Node3D

var land : MeshInstance3D
var noise = FastNoiseLite.new()

func created_texture(wid: int, height: int) -> ImageTexture:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_type = FastNoiseLite.FRACTAL_PING_PONG
	noise.fractal_gain = 0.5
	noise.fractal_ping_pong_strength = 10
	noise.fractal_weighted_strength = 1.5
	noise.domain_warp_type = FastNoiseLite.DOMAIN_WARP_SIMPLEX_REDUCED
	noise.domain_warp_fractal_octaves = 16
	
	noise.frequency = 0.0019
	noise.fractal_lacunarity = 1.5
	noise.fractal_octaves = 5.0
	noise.seed = 14  

	var image = noise.get_seamless_image(wid, height)
	for i in range(wid):
		for j in range(height):
			var noise_val = (image.get_pixel(i, j).r + 1) / 2  # add an offset to the noise value
			var brown_color = Color(0.1, 0.04, 0)  # Brown color
			var colored_pixel = Color(
				brown_color.r * noise_val,
				brown_color.g * noise_val,
				brown_color.b * noise_val,
				1.0
			)
			image.set_pixel(i, j, colored_pixel)
	return ImageTexture.create_from_image(image)

func _ready() -> void:
	land = MeshInstance3D.new()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count : Array[int] = [0]
	
	#var noise = FastNoiseLite.new()
	#var image = noise.get_image(512, 512)
	#var texture = ImageTexture.create_from_image(image)
	#var material = StandardMaterial3D.new()
	#material.albedo_texture = texture
	
	var texture = created_texture(512, 512)
	var material = StandardMaterial3D.new()
	material.albedo_texture = texture
	material.vertex_color_use_as_albedo = true
	
	for i in range(64):
		for j in range(64):
			var noiseVal1 = noise.get_noise_2d(i, j) * 10
			var noiseVal2 = noise.get_noise_2d(i+1, j) * 10
			var noiseVal3 = noise.get_noise_2d(i+1, j+1) * 10
			var noiseVal4 = noise.get_noise_2d(i, j+1) * 10
			
			
			
			
			
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
	
	var brown_color = Color(0.55,0.1,0.1)
	
	st.set_uv( Vector2(0, 0) )
	st.set_color(brown_color * ((noiseVal1 + 1) / 2))
	st.add_vertex(pt + Vector3(0, noiseVal1, 0) ) # vertex 0
	count[0] += 1
	st.set_uv( Vector2(1, 0) )
	st.set_color(brown_color * ((noiseVal2 + 1) / 2))
	st.add_vertex(pt +  Vector3(1, noiseVal2, 0) ) # vertex 1
	count[0] += 1
	st.set_uv( Vector2(1, 1) )
	st.set_color(brown_color * ((noiseVal3 + 1) / 2))
	st.add_vertex(pt +  Vector3(1, noiseVal3, 1) ) # vertex 2
	count[0] += 1
	st.set_uv( Vector2(0, 1) )
	st.set_color(brown_color * ((noiseVal4 + 1) / 2))
	st.add_vertex(pt +  Vector3(0, noiseVal4, 1) ) # vertex 3
	count[0] += 1
	
	st.add_index(count[0] - 4) # make the first triangle
	st.add_index(count[0] - 3)
	st.add_index(count[0] - 2)
	
	st.add_index(count[0] - 4) # make the second triangle
	st.add_index(count[0] - 2)
	st.add_index(count[0] - 1)
