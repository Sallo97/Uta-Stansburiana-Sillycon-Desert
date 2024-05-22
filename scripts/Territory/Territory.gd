class_name Territory

var owner_lizard: Lizard
var females: Array[Lizard] = []
var size: float
var color: Color
var desert
var cells: Array[Vector2i]

func _init(desert_ref, distance_calculator_ref, grid_ref, owner: Lizard):
	owner_lizard = owner
	match owner_lizard.morph:
		Constants.Morph.ORANGE:
			size = Constants.orange_territory_size * SceneData.get_territory_multiplier(1.0)
		Constants.Morph.BLUE:
			size = Constants.blue_territory_size * SceneData.get_territory_multiplier(1.0)
	color = Constants.Color_Values.ret_color(owner_lizard.morph)
	desert = desert_ref
	cells = DistanceCalculator.instance().get_cells_within_distance(DistanceCalculator.instance().get_cell_at_position(owner_lizard.position), size).filter(DistanceCalculator.instance().is_valid_cell)
	# print_debug(cells)
	draw()

func set_new_owner(lizard: Lizard):
	delete()
	owner_lizard = lizard
	color = Constants.Color_Values.ret_color(owner_lizard.morph)
	draw()

func draw():
	desert.draw_pixel_array(cells, color)

func delete():
	desert.draw_pixel_array(cells, color, true)	
