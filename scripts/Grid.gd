extends Node

var cells: Array
var size: Vector2i

func _ready():
	setup()

func setup():
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
