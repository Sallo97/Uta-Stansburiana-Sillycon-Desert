extends Node

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
	# print_debug(%Grid.get_cell_heightv(center))
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
			if (cell.x < 0) || (cell.x >= %Grid.size.x) || (cell.y < 0) || (cell.y >= %Grid.size.y) || (visited.has(cell)):
				continue
			var newDist: float = currentDistance - get_traversal_difficulty_slope(cell, currentPos)
			# print(%Grid.get_cell_heightv(cell))
			if newDist >= 0:
				out.append(cell)
				queue.enqueue([cell, newDist])
				visited.append(cell)
		iterations += 1
	return out


# Compute the traversal difficulty taking into consideration the height of the terrain
func get_traversal_difficulty(cell: Vector2i) -> float:
	return (((%Grid.get_cell_heightv(cell) * 2) - 0.9) * 4) + 0.9


# Compute the traversal difficulty taking into account the slope (relative height)
# of the cell where a lizard is, and the one it is travelling to
func get_traversal_difficulty_slope(cell: Vector2i, from: Vector2i) -> float:
	return randf_range(0.7, 1.3) + ((%Grid.get_cell_heightv(cell) - %Grid.get_cell_heightv(from)) * SLOPE_MULTIPLIER)


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
	var max: Array = [cells[0], %Grid.get_cell_heightv(cells[0])]
	for c in cells.slice(1):
		var cell_height: float = %Grid.get_cell_heightv(c)
		if cell_height > max[1]:
			max = [c, cell_height]
	return max


func max_height_in_circle(center: Vector2i, radius: int) -> Array:
	var cells: Array[Vector2i] = rasterize_circle(center, radius)
	return max_height(cells)
