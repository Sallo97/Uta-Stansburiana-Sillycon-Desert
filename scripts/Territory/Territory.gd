class_name Territory

var owner_lizard: Lizard
var size: float
var color: Color
var desert
var cells: Array[Vector2i]

func _init(desert_ref, distance_calculator_ref, grid_ref, owner: Lizard):
	owner_lizard = owner
	match owner_lizard.morph:
		Constants.Morph.ORANGE:
			size = Constants.orange_territory_size
		Constants.Morph.BLUE:
			size = Constants.blue_territory_size
	color = Constants.Color_Values.ret_color(owner_lizard.morph)
	desert = desert_ref
	cells = DistanceCalculator.instance().get_cells_within_distance(DistanceCalculator.instance().get_cell_at_position(owner_lizard.position), size)
	# print_debug(cells)
	draw()

func draw():
	desert.draw_pixel_array(cells, color)

func delete():
	desert.draw_pixel_array(cells, color, true)	
