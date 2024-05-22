extends RefCounted
class_name DistanceCalculator

static var __instance: DistanceCalculator

func _init():
	assert(__instance == null)
	__instance = self

static func instance() -> DistanceCalculator:
	if __instance == null:
		return DistanceCalculator.new()
	else:
		return __instance


const MAX_ITERATIONS = 200
const SLOPE_MULTIPLIER = 50


func _ready():
	pass # Replace with function body.


func distance(p1: Vector2, p2: Vector2i):
	# return grid.get_cell_height(p1.x, p1.y)
	return p1.distance_to(p2)


@warning_ignore("shadowed_variable")
func get_cells_within_distance(center: Vector2i, distance: float) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var queue := Queue.new()
	var visited: Array[Vector2i] = []
	out.append(center)
	queue.enqueue([center, distance - get_traversal_difficulty_slope(center, center)])
	# print_debug(Grid.instance().get_cell_heightv(center))
	visited.append(center)

	var iterations := 0
	while !queue.is_empty() && iterations < MAX_ITERATIONS:
		# print(queue)
		var current: Array = queue.dequeue()
		var currentPos: Vector2i = current[0]
		var currentDistance: float = current[1]
		var adjacentCells: Array = [
			Vector2i(currentPos.x-1, currentPos.y),
			Vector2i(currentPos.x+1, currentPos.y),
			Vector2i(currentPos.x, currentPos.y-1),
			Vector2i(currentPos.x, currentPos.y+1)
		]
		for cell in adjacentCells:
			if (cell.x < 0) || (cell.x >= Grid.instance().size.x) || (cell.y < 0) || (cell.y >= Grid.instance().size.y) || (visited.has(cell)):
				continue
			var newDist: float = currentDistance - get_traversal_difficulty_slope(cell, currentPos)
			# print(Grid.instance().get_cell_heightv(cell))
			if newDist >= 0:
				out.append(cell)
				queue.enqueue([cell, newDist])
				visited.append(cell)
		iterations += 1
	return out


# Compute the traversal difficulty taking into consideration the height of the terrain
func get_traversal_difficulty(cell: Vector2i) -> float:
	return (((Grid.instance().get_cell_heightv(cell) * 2) - 0.9) * 4) + 0.9


# Compute the traversal difficulty taking into account the slope (relative height)
# of the cell where a lizard is, and the one it is travelling to
func get_traversal_difficulty_slope(cell: Vector2i, from: Vector2i) -> float:
	return randf_range(0.7, 1.3) + ((Grid.instance().get_cell_heightv(cell) - Grid.instance().get_cell_heightv(from)) * SLOPE_MULTIPLIER)


# https://en.wikipedia.org/wiki/Midpoint_circle_algorithm#Jesko's_Method
func rasterize_circle(center: Vector2i, radius: int) -> Array[Vector2i]:
	@warning_ignore("integer_division")
	var t1: int = radius / 16
	var x: int = radius
	var y: int = 0
	var out: Array[Vector2i] = []
	while x >= y:
		out.append(Vector2i(x, y) + center)
		out.append(Vector2i(-x, y) + center)
		out.append(Vector2i(x, -y) + center)
		out.append(Vector2i(-x, -y) + center)
		out.append(Vector2i(y, x) + center)
		out.append(Vector2i(-y, x) + center)
		out.append(Vector2i(y, -x) + center)
		out.append(Vector2i(-y, -x) + center)
		y = y + 1
		t1 = t1 + y
		var t2: int = t1 - x
		if t2 >= 0:
			t1 = t2
			x = x - 1
	return out


func max_height(cells: Array[Vector2i]) -> Array:
	@warning_ignore("shadowed_global_identifier")
	var max: Array = [cells[0], Grid.instance().get_cell_heightv(cells[0])]
	for c in cells.slice(1):
		var cell_height: float = Grid.instance().get_cell_heightv(c)
		if cell_height > max[1]:
			max = [c, cell_height]
	return max


func max_height_in_circle(center: Vector2i, radius: int) -> Array:
	var cells: Array[Vector2i] = rasterize_circle(center, radius)
	return max_height(cells)


func get_cell_at_position(absolute_position: Vector3) -> Vector2i:
	var desert_aabb: AABB = Grid.instance().__desert.get_aabb()
	var obj_pos_2d: Vector2 = Vector2(absolute_position.x, absolute_position.z)
	var desert_pos_2d: Vector2 = Vector2(desert_aabb.position.x, desert_aabb.position.z)

	var position_relative_to_desert = obj_pos_2d - desert_pos_2d
	var desert_size: Vector2 = Vector2(desert_aabb.size.x, desert_aabb.size.z)

	var out = (position_relative_to_desert / desert_size) * Vector2(Grid.instance().size)
	out = Vector2i(floor(out.x), floor(out.y))
	return out


func get_position_of_cell(cell: Vector2i) -> Vector3:
	var desert_aabb: AABB = Grid.instance().__desert.get_aabb()
	var desert_pos_2d: Vector2 = Vector2(desert_aabb.position.x, desert_aabb.position.z)
	var desert_size: Vector2 = Vector2(desert_aabb.size.x, desert_aabb.size.z)
	var cell_size: Vector2 = Vector2(Grid.instance().size) / desert_size

	var pos_2d := (Vector2(cell) * cell_size) + desert_pos_2d
	return Vector3(pos_2d.x, Grid.instance().get_cell_heightv(cell), pos_2d.y)


func is_valid_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 && cell.x < Grid.instance().size.x && cell.y >= 0 && cell.y < Grid.instance().size.y
