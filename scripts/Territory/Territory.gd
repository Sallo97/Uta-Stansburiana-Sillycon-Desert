class_name Territory

var owner_lizard: Lizard
var size: float
var color: Color
var desert
var distance_calculator
var grid
var cells: Array[Vector2i]

func _init(desert_ref, distance_calculator_ref, grid_ref, owner: Lizard):
	owner_lizard = owner
	size = 10
	color = Constants.Color_Values.ret_color(owner_lizard.morph)
	desert = desert_ref
	distance_calculator = distance_calculator_ref
	grid = grid_ref
	cells = distance_calculator.get_cells_within_distance(distance_calculator.get_cell_at_position(owner_lizard.position), size)
	draw()

func draw():
	desert.draw_pixel_array(cells, color)

func delete():
	desert.draw_pixel_array(cells, color, true)	
