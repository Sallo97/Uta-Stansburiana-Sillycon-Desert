extends Node

var cells: Array
var size: Vector2i
var territories: Array[Territory] = []

func _ready():
	setup()

func setup():
	territories.clear()
	size = %Desert.size
	print_debug("Initializing grid with {a}".format({"a": size}))
	cells.resize(size.x)
	for x in size.x:
		cells[x] = Array()
		cells[x].resize(size.y)
		for y in size.y:
			cells[y] = Cell.new()


func get_cell_height(x: int, y: int) -> float:
	return %Desert.height_map.get_pixel(x, y)[0]


func get_cell_heightv(pos: Vector2i) -> float:
	return get_cell_height(pos.x, pos.y)


func get_size() -> Vector2i:
	return size


func create_territory(lizard):
	territories.append(Territory.new(%Desert, %DistanceCalculator, self, lizard))


func get_grid_position(absolute_position: Vector3) -> Vector2i:
	var desert_aabb: AABB = %Desert.get_aabb()
	var obj_pos_2d: Vector2 = Vector2(absolute_position.x, absolute_position.z)
	var desert_pos_2d: Vector2 = Vector2(desert_aabb.position.x, desert_aabb.position.z)

	var position_relative_to_desert = obj_pos_2d - desert_pos_2d
	var desert_size: Vector2 = Vector2(desert_aabb.size.x, desert_aabb.size.z)

	var out = (position_relative_to_desert / desert_size) * Vector2(size)
	out = Vector2i(floor(out.x), floor(out.y))
	print_debug(obj_pos_2d)
	print_debug(out)
	return out
