class_name Constants


#---------CONSTANTS----------------------------------

# Size values are in mm
const min_size : int = 20
const max_size : int = 30

# Speed of the lizard is in meters per second
const min_speed = 50
const max_speed = 50

# Downward acceleration when in the air, in meters per seconds squared.
const fall_acceleration = 100

#-----------ENUMS--------------------------------------
class Color_Values:
	const yellow_color  :  Color  = Color(0.7, 0.5, 0.2,  1)
	const orange_color  :  Color  = Color(1, 0.4, 0.2,  1)
	const blue_color    :  Color  = Color(0.039, 0.35, 1, 1)

	static func ret_color(morph):
		match(morph):
			Morph.ORANGE : return orange_color
			Morph.YELLOW : return yellow_color
			Morph.BLUE : return blue_color

# Morph type (it depends on the color of the lizard)
enum Morph {ORANGE = 0, YELLOW = 1, BLUE = 2}

# Sex type
enum Sex {MALE = 0, FEMALE = 1}
