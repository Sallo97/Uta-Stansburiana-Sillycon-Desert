extends RefCounted
class_name Grid

static var __instance: Grid

func _init():
	assert(__instance == null)
	__instance = self

static func instance() -> Grid:
	if __instance == null:
		return Grid.new()
	else:
		return __instance


var cells: Array = []
var size: Vector2i
var territories: Array[Territory] = []

var __desert: Node


func setup(desert_ref: Node):
	__desert = desert_ref
	territories.clear()
	cells.clear()
	size = __desert.size
	print_debug("Initializing grid with {a}".format({"a": size}))
	cells.resize(size.x)
	for x in size.x:
		cells[x] = Array()
		cells[x].resize(size.y)
		for y in size.y:
			cells[x][y] = Cell.new()


func get_cell_height(x: int, y: int) -> float:
	return __desert.height_map.get_pixel(x, y)[0]


func get_cell_heightv(pos: Vector2i) -> float:
	return get_cell_height(pos.x, pos.y)


func get_size() -> Vector2i:
	return size


func create_territory(lizard: Lizard):
	var new_territory: Territory = Territory.new(__desert, DistanceCalculator.instance(), self, lizard)
	territories.push_back(new_territory)
	for c in new_territory.cells:
		cells[c.x][c.y].add_territory(new_territory)


func destroy_territory(lizard: Lizard):
	var territory = territories.filter(func (t: Territory): return t.owner_lizard == lizard)
	if territory.size() != 0:
		territory = territory[0]
	territories.erase(territory)
	for c in territory.cells:
		c.remove_territory(territory)


func cell_entered(lizard: Lizard):
	# print_debug("Checking cells that ", lizard.morph, " entered")
	var cell_pos: Vector2i = DistanceCalculator.instance().get_cell_at_position(lizard.position)
	if !DistanceCalculator.instance().is_valid_cell(cell_pos):
		# Lizard tried to check cells while it was outside of the map
		return
	var cell: Cell = cells[cell_pos.x][cell_pos.y]
	for t in cell.territories:
		if t.owner_lizard != lizard && !lizard.current_territories.has(t):
			t.owner_lizard.on_other_lizard_entered_territory(lizard)
			lizard.on_entered_territory(t)
	lizard.current_territories = cell.territories
