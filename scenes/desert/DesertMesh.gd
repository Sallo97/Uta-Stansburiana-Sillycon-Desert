extends MeshInstance3D

@export var size: Vector2i = Vector2i(100, 100)
@export var noise_multiplier: float = 10.0
@export var model_height: bool = false
@export var mesh_simplification: int = 4

@export var collision_offset: Vector3 = Vector3.UP

@export var noise_texture_multiplier: float = 1.0
@export var noise_texture_scale: float = 1.0
@export var desert_texture: CompressedTexture2D
@export var desert_texture_scale: float = 2.0

var overlay_material: StandardMaterial3D
var overlay_image: Image
var overlay_texture: ImageTexture

var material: StandardMaterial3D
var texture: ImageTexture
var height_map: Image

func _ready():
	material = preload("res://assets/3D/materials/desertMaterial.tres")
	texture  = ImageTexture.new()
	reset()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func reset():
	size = SceneData.get_desert_size(size)
	%Grid.setup()

	var noise_image: Image = generate_noise_map(10, 10, 0, Vector2(size.x + 2, size.y + 2))
	generatePlaneMeshXZ(noise_image)
	create_trimesh_collision()
	var static_body: StaticBody3D = get_node("./Desert_col")
	static_body.translate(collision_offset)
	# print(static_body.transform.origin)
	
	height_map = Image.new()
	height_map.copy_from(noise_image)
	# ResourceSaver.save(mesh, "res://assets/2D/textures/plane.tres", ResourceSaver.FLAG_COMPRESS)
	multiply_image(noise_image, noise_texture_multiplier)
	# noise_image.save_png("res://assets/2D/textures/plane.png")
	
	noise_image.resize(int(noise_image.get_size().x * noise_texture_scale), int(noise_image.get_size().y * noise_texture_scale), Image.INTERPOLATE_BILINEAR)
	combine_images(noise_image, desert_texture.get_image(), desert_texture_scale)
	texture.set_image(noise_image)
	material.set("albedo_texture", texture)
	mesh.surface_set_material(0, material)
	
	# Initialize overlay texture
	overlay_material = get_material_overlay()
	overlay_image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	overlay_texture = ImageTexture.create_from_image(overlay_image)
	overlay_material.set("albedo_texture", overlay_texture)
	
	# Start debug timer
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = 5
	timer.start()
	timer.timeout.connect(set_random_pixel)


func set_random_pixel():
	var x = randi_range(0, overlay_image.get_size().x - 1)
	var y = randi_range(0, overlay_image.get_size().y - 1)
	
	# var _territory: Territory = Territory.new(self, %DistanceCalculator, %Grid, {"position": Vector2i(x, y), "morph": [Constants.Morph.ORANGE, Constants.Morph.YELLOW, Constants.Morph.BLUE][randi_range(0,2)]})
	#territory.delete()
	
	# var circle: Array[Vector2i] = %DistanceCalculator.rasterize_circle(Vector2i(x, y), 10)
	# draw_pixel_array(circle, Color.ALICE_BLUE)
	# set_overlay_pixelv(%DistanceCalculator.max_height(circle)[0], Color.REBECCA_PURPLE)

	# print_debug((%DistanceCalculator as DistanceCalculator))


func set_overlay_pixel(x: int, y: int, color: Color, delete = false):
	var original_color := overlay_image.get_pixel(x, y)
	var new_color: Color
	if !delete:
		if original_color == Color(0,0,0,0):
			new_color = color
		else:
			new_color = original_color * color
	else:
		if original_color == color:
			new_color = Color(0,0,0,0)
		else:
			new_color = original_color / color
	overlay_image.set_pixel(x, y, new_color)
	overlay_texture.set_image(overlay_image)

func set_overlay_pixelv(point: Vector2i, color: Color, delete = false):
	set_overlay_pixel(point.x, point.y, color, delete)

func draw_pixel_array(cells: Array[Vector2i], color: Color, delete = false):
	for c in cells:
		var original_color := overlay_image.get_pixelv(c)
		var new_color: Color
		if !delete:
			if original_color == Color(0,0,0,0):
				new_color = color
			else:
				new_color = original_color * color
		else:
			if original_color == color:
				new_color = Color(0,0,0,0)
			else:
				new_color = original_color / color
		overlay_image.set_pixelv(c, new_color)
	overlay_texture.set_image(overlay_image)


func draw_territory(pos: Vector2i, distance: float, color: Color, delete = false):
	var cells: Array[Vector2i] = %DistanceCalculator.get_cells_within_distance(pos, distance)
	draw_pixel_array(cells, color, delete)


func multiply_image(img: Image, factor: float):
	for x in img.get_size().x:
		for y in img.get_size().y:
			img.set_pixel(x, y, (img.get_pixel(x, y) * factor + ((1 - factor) * Color.GAINSBORO)))

@warning_ignore("shadowed_variable_base_class")
func combine_images(img1: Image, img2: Image, scale: float):
	for x in img1.get_size().x:
		for y in img1.get_size().y:
			var img2Coords: Vector2i = Vector2i(int(x * scale) % img2.get_size().x, int(y * scale) % img2.get_size().y)
			img1.set_pixel(x, y, (img1.get_pixel(x, y) * img2.get_pixelv(img2Coords)))

# https://medium.com/@cece9200/godot-4-c-generating-terrain-with-simplex-noise-a3150a6e393f
@warning_ignore("shadowed_global_identifier", "shadowed_variable")
func generate_noise_map(seed: int, octaves: int, gain: float, size: Vector2i):
	var noise := FastNoiseLite.new()
	noise.seed = seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_octaves = octaves
	noise.fractal_gain = gain
	
	var img = noise.get_image(size.x, size.y, false, false, false)
	return img


# https://www.reddit.com/r/godot/comments/kf9ikv/comment/gg7j6t8/?utm_source=share&utm_medium=web2x&context=3
func generatePlaneMeshXZ(_noise_img):
	var vertices := PackedVector3Array()
	var uv := PackedVector3Array()
	@warning_ignore("integer_division")
	var xVertexCount := 2 + (size.x / mesh_simplification)
	@warning_ignore("integer_division")
	var zVertexCount := 2 + (size.y / mesh_simplification)
	var img_size: Vector2i = _noise_img.get_size() - Vector2i.ONE
	vertices.resize(xVertexCount * zVertexCount)
	uv.resize(vertices.size())
	var i := 0
	for zIdx in range(zVertexCount):
		var tz := zIdx / float(zVertexCount - 1)
		for xIdx in range(xVertexCount):
			var tx := xIdx / float(xVertexCount - 1)
			var height = _noise_img.get_pixel(min(xIdx * mesh_simplification, img_size.x), min(zIdx * mesh_simplification, img_size.y) )[0] * noise_multiplier
			var vertexPosition := Vector3((tx - 0.5) * size.x, height if model_height else 0, (tz - 0.5) * size.y)
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
