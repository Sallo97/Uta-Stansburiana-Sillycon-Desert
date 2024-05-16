extends MeshInstance3D

@export var size: Vector2i = Vector2i(300, 300)
@export var noise_multiplier: float = 10.0
@export var territory_colours: Array[Color]

var overlay_material: StandardMaterial3D
var overlay_image: Image
var overlay_texture: ImageTexture

func _ready():
	generatePlaneMeshXZ(generate_noise_map(10, 10, 0, Vector2(size.x + 2, size.y + 2)))
	var noise_image: Image = generate_noise_map(10, 10, 0, Vector2(size.x + 2, size.y + 2))
	multiply_image(noise_image, 0.5, 0.5)
	noise_image.save_png("res://plane.png")
	#get_material_override().set("albedo_texture", noise_image)
	var mat: StandardMaterial3D = preload("res://assets/3D/materials/desertMaterial.tres")
	var tex: ImageTexture = ImageTexture.create_from_image(noise_image)
	mat.set("albedo_texture", tex)
	mesh.surface_set_material(0, mat)
	
	#ResourceSaver.save(get_material_override(), "res://desertMaterial.tres", ResourceSaver.FLAG_COMPRESS)
	
	# Initialize overlay texture
	ResourceSaver.save(mesh, "res://plane.tres", ResourceSaver.FLAG_COMPRESS)
	overlay_material = get_material_overlay()
	overlay_image = Image.create(size.x + 2, size.y + 2, false, Image.FORMAT_RGBA8)
	overlay_texture = ImageTexture.create_from_image(overlay_image)
	overlay_material.set("albedo_texture", overlay_texture)
	
	# Start timer that sets random pixels to red
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = 0.1
	timer.start()
	timer.timeout.connect(set_random_pixel)

func set_random_pixel():
	var x = randi_range(0, size.x + 2)
	var y = randi_range(0, size.y + 2)
	set_overlay_pixel(x, y, Color.RED)
	
func set_overlay_pixel(x: int, y: int, color: Color):
	overlay_image.set_pixel(x, y, color)
	overlay_texture.set_image(overlay_image)

func multiply_image(img: Image, factor: float, shift: float):
	for x in img.get_size().x:
		for y in img.get_size().y:
			img.set_pixel(x, y, (img.get_pixel(x, y) * factor + ((1 - factor) * Color.GAINSBORO)))

# https://medium.com/@cece9200/godot-4-c-generating-terrain-with-simplex-noise-a3150a6e393f
func generate_noise_map(seed, octaves, gain, size):
	var noise := FastNoiseLite.new()
	noise.seed = seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_octaves = octaves
	noise.fractal_gain = gain
	# noise.get_noise_2d(0,0)
	var img = noise.get_image(size.x, size.y, false, false, false)
	return img


# https://www.reddit.com/r/godot/comments/kf9ikv/comment/gg7j6t8/?utm_source=share&utm_medium=web2x&context=3
func generatePlaneMeshXZ(noise_img):
	var vertices := PackedVector3Array()
	var uv := PackedVector3Array()
	var xVertexCount := 2 + size.x
	var zVertexCount := 2 + size.y
	vertices.resize(xVertexCount * zVertexCount)
	uv.resize(vertices.size())
	var i := 0
	for zIdx in range(zVertexCount):
		var tz := zIdx / float(zVertexCount - 1)
		for xIdx in range(xVertexCount):
			var tx := xIdx / float(xVertexCount - 1)
			var height = noise_img.get_pixel(xIdx, zIdx)[0] * noise_multiplier
			var vertexPosition := Vector3((tx - 0.5) * size.x, height, (tz - 0.5) * size.y)
			vertices[i] = vertexPosition
			uv[i] = Vector3(float(xIdx) / xVertexCount, float(zIdx) / zVertexCount, 0.0)
			i += 1
	
	var indices := PackedInt32Array()
	var xQuadCount := xVertexCount - 1
	var zQuadCount := zVertexCount - 1
	indices.resize(xQuadCount * zQuadCount * 6)
	i = 0
	for zIdx in range(zQuadCount):
		for xIdx in range(xQuadCount):
			#  a-b
			#  | |
			#  c-d
			var aIdx := zIdx * xVertexCount + xIdx
			var bIdx := aIdx + 1
			var cIdx := aIdx + xVertexCount
			var dIdx := aIdx + xVertexCount + 1
			
			if (zIdx + xIdx) % 2:
				#  a-b
				#   \|
				#    d
				indices[i + 0] = aIdx
				indices[i + 1] = bIdx
				indices[i + 2] = dIdx
				
				#  a  
				#  |\ 
				#  c-d
				indices[i + 3] = aIdx
				indices[i + 4] = dIdx
				indices[i + 5] = cIdx

			else:
				#  a-b
				#  |/ 
				#  c  
				indices[i + 0] = aIdx
				indices[i + 1] = bIdx
				indices[i + 2] = cIdx
				
				#    b
				#   /|
				#  c-d
				indices[i + 3] = bIdx
				indices[i + 4] = dIdx
				indices[i + 5] = cIdx
			
			i += 6
	
	var arrays := []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	arrays[ArrayMesh.ARRAY_INDEX] = indices
	arrays[ArrayMesh.ARRAY_TEX_UV] = uv
	computeNormals(arrays)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)


# https://stackoverflow.com/questions/6656358/calculating-normals-in-a-triangle-mesh/57812028#57812028
func computeNormals(surface_arrays):
	var normals: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = surface_arrays[ArrayMesh.ARRAY_INDEX]
	var vertices: PackedVector3Array = surface_arrays[ArrayMesh.ARRAY_VERTEX]

	# Init normals array
	normals.resize(vertices.size())

	for i in range(0, indices.size(), 3):
		# Get the face normal
		var vector1: Vector3 = vertices[indices[i + 1]] - vertices[indices[i]]
		var vector2: Vector3 = vertices[indices[i + 2]] - vertices[indices[i]]
		var faceNormal: Vector3 = vector1.cross(vector2)
		faceNormal = faceNormal.normalized()

		# Add the face normal to the 3 vertices normal touching this face
		normals[indices[i]] 	+= faceNormal
		normals[indices[i + 1]] += faceNormal
		normals[indices[i + 2]] += faceNormal

	# Normalize vertices normal
	for i in normals.size():
		normals[i] = normals[i].normalized()

	surface_arrays[ArrayMesh.ARRAY_NORMAL] = normals


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
