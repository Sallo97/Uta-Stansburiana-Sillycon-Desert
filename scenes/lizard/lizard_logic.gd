extends CharacterBody3D

#---------CONSTANTS----------------------------------

# Size values are in mm
const min_size : int = 20
const max_size : int = 30

# Speed of the lizard is in meters per second
const min_speed = 2
const max_speed = 4

# Morph type (it depends on the color of the lizard)
enum Morph {ORANGE = 0, YELLOW = 1, BLUE = 2}

# Sex type
enum Sex {MALE = 0, FEMALE = 1}

class Color_Values:
	const yellow_color  :  Color  = Color(0.7, 0.5, 0.2,  1)
	const orange_color  :  Color  = Color(1, 0.4, 0.2,  1)
	const blue_color    :  Color  = Color(0.039, 0.35, 1, 1)

	static func ret_color(morph):
		match(morph):
			Morph.ORANGE : return orange_color
			Morph.YELLOW : return yellow_color
			Morph.BLUE : return blue_color
			
#--------VARIABLES--------------------------------

var sex : Sex
var morph : Morph
var size : int


# Nodes
@onready var lizard_node : Node3D = get_node("Pivot/lizard")
@onready var body_node : MeshInstance3D = lizard_node.get_node("Body")

#---------SETTING FUNC--------------------

# It chooses randomly the sex of the lizard.
# Getting a male or a female is equiprobable
func randomSex():
	var sex_prob : int = randi_range(0, 1) 
	return sex_prob


# It chooses randomly the morph of the lizard.
# all the colors are equiprobable
func randomMorph():
	var rand : int = 0
	match (sex):
		Sex.MALE:
			rand = randi_range(0,2)
		Sex.FEMALE:
			rand = randi_range(0,1)
	return rand

# It chooses randomly the size of the lizard.
# baseSize = [20…30]mm
# size = baseSize + (male ? 10 : 0) + (orange ? 10 : 0))
# size cannot be > 60
func randomSize():
	var baseSize : int = randi_range(min_size, max_size) 
	if(sex == Sex.MALE):
		baseSize += 10
	if (morph == Morph.ORANGE):
		baseSize += 10
	if (baseSize > 60):
		baseSize = 60
	return baseSize


#--------------MODIFY MESH FUNC------------

# This function sets the color of the body 
# ONLY on THIS instance of the lizard
func set_body_color():
	var material = StandardMaterial3D.new()
	material.albedo_color = Color_Values.ret_color(morph)
	body_node.material_override = material

# This function sets the size of the ONLY
# THIS instance of the lizard
func set_lizard_size():
	var scale_value : float = float(size) / float(min_size) # 1 : 20 = scale_value : size 
	lizard_node.global_scale( Vector3(scale_value,scale_value,scale_value) )

#------------MOVEMENT FUNC----------------------------------------

func _physics_process(delta):
	move_and_slide()

func initialize(start_position):
	rotate_y(randf_range(-PI / 4, PI / 4))
	var random_speed = randi_range(min_speed, max_speed)
	velocity = Vector3.FORWARD * random_speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)

#---------------READY FUNC-------------------------------
func _ready():
	sex = randomSex()
	morph = randomMorph()
	size = randomSize()

	set_body_color()
	set_lizard_size()
