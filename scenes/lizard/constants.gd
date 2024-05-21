class_name Constants
#---------CONSTANTS----------------------------------

# Size values are in mm
const min_size : int = 20
const max_size : int = 30

# Speed of the lizard is in meters per second
const min_speed:float = 50.0
const max_speed:float = 50.0

# Max allowed velocity
const max_velocity = 200

# Time in seconds
const max_lifetime:float = 30.0
const min_lifetime:float = 10.0

# Time in seconds
const max_grow_up_timer:float = 5.0
const min_grow_up_timer:float = 2.0

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
class Alleles_Comb:
	const orange_comb =[ 
					[Allele.O, Allele.O], [Allele.O, Allele.B],
					[Allele.O, Allele.Y], [Allele.B, Allele.O],
					[Allele.Y, Allele.O] ]
	const blue_comb = [ 
					[Allele.B, Allele.B] ]
	const yellow_comb = [ 
					[Allele.Y, Allele.Y], [Allele.Y, Allele.B],
					[Allele.B, Allele.Y] ]
	
	static func ret_morph(comb):
		if(orange_comb.find(comb)):
			return Morph.ORANGE
		elif(blue_comb.find(comb)):
			return Morph.BLUE
		elif(yellow_comb.find(comb)):
			return Morph.YELLOW
			
# Morph type (it depends on the color of the lizard)
enum Morph {ORANGE = 0, YELLOW = 1, BLUE = 2}

# Sex type
enum Sex {MALE = 0, FEMALE = 1}

# Allele type
enum Allele {O = 0, B = 1, Y = 2}

#------------FUNC----------------------------

# It determines the alleles depending on the
# morph of the lizard
static func set_random_alleles(morph:Constants.Morph,
			prob_o = 0.5, prob_b = 0.5, prob_y = 0.5):
	var allele_1:Constants.Allele
	var allele_2:Constants.Allele
	
	var is_orange:bool = randf() <= prob_o
	var is_blue:bool = randf() <= prob_b
	var is_yellow:bool = randf() <= prob_y

	if (morph == Constants.Morph.ORANGE):
		allele_1 = Constants.Allele.O
		if(is_orange):
			allele_2 = Constants.Allele.O
		elif(is_blue):
			allele_2 = Constants.Allele.B
		elif(is_yellow):
			allele_2 = Constants.Allele.Y
	
	elif (morph == Constants.Morph.BLUE):
		allele_1 = Constants.Allele.B
		allele_2 = Constants.Allele.B
	
	elif (morph == Constants.Morph.YELLOW):
		allele_1 = Constants.Allele.Y
		if(is_blue):
			allele_2 = Constants.Allele.B
		elif(is_yellow):
			allele_2 = Constants.Allele.Y
	return [allele_1, allele_2]
	
static func set_alleles(sex, papa_al, mama_al):
	print("papa_al = ", papa_al)
	print("mama_al = ", mama_al)
	
	var idx_p = randi_range(0,1)
	var idx_m = randi_range(0,1)
	var A_p = papa_al[idx_p]
	var A_m = mama_al[idx_m]
	
	if sex==Constants.Sex.FEMALE and A_p == Constants.Allele.B and A_m == Constants.Allele.B:
		idx_m = absi(idx_m - 1)
		A_m = mama_al[idx_m]
		
	print("child_al = ", [A_p, A_m])
	return [A_p, A_m]
