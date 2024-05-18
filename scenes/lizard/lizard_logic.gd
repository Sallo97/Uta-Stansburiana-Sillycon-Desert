extends CharacterBody3D
#-----------SCRIPTS--------------------
var scpt = load("res://scenes/lizard/constants.gd")

#------------NODES---------------------------------
@onready var lizard_node : Node3D = get_node("Pivot/lizard")
@onready var body_node : MeshInstance3D = lizard_node.get_node("Body")
@onready var lips_node : MeshInstance3D = lizard_node.get_node("Lips")
@onready var ribbon_node : MeshInstance3D = lizard_node.get_node("Ribbon")


#---------CONSTANTS----------------------------------

# Size values are in mm
const min_size : int = 20
const max_size : int = 30

# Speed of the lizard is in meters per second
const min_speed = 50
const max_speed = 50

# Downward acceleration when in the air, in meters per seconds squared.
var fall_acceleration = 100
			
#--------VARIABLES--------------------------------

var sex
var morph
var size : int
var falling: bool = true
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
		scpt.Sex.MALE:
			rand = randi_range(0,2)
		scpt.Sex.FEMALE:
			rand = randi_range(0,1)
	return rand

# It chooses randomly the size of the lizard.
# baseSize = [20…30]mm
# size = baseSize + (male ? 10 : 0) + (orange ? 10 : 0))
# size cannot be > 60
func randomSize():
	var baseSize : int = randi_range(min_size, max_size) 
	if(sex == scpt.Sex.MALE):
		baseSize += 10
	if (morph == scpt.Morph.ORANGE):
		baseSize += 10
	if (baseSize > 60):
		baseSize = 60
	return baseSize

#--------------MODIFY MESH FUNC------------

# This function sets the color of the body 
# ONLY on THIS instance of the lizard
func set_body_color():
	var material = StandardMaterial3D.new()
	material.albedo_color = scpt.Color_Values.ret_color(morph)
	body_node.material_override = material

# This function sets the size of the ONLY
# THIS instance of the lizard
func set_lizard_size():
	var scale_value : float = float(size) / float(min_size) # 1 : 20 = scale_value : size 
	lizard_node.global_scale( Vector3(scale_value,scale_value,scale_value) )

# This function removes the ribbon and the lips from the mesh
# if the current lizard is male
func male_mesh():
	if (sex == scpt.Sex.MALE) :
		lips_node.hide()
		ribbon_node.hide()

#------------MOVEMENT FUNC----------------------------------------

func _physics_process(delta):
	if falling:
		velocity.y = velocity.y - (fall_acceleration * delta)
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
	else :
		velocity = Vector3.FORWARD * randi_range(min_speed,max_speed)
		velocity = velocity.rotated(Vector3.UP, rotation.y)
		if not is_on_floor():
			velocity.y = velocity.y - (fall_acceleration * delta)

	if is_on_floor_only():
		falling = false
	
	if not is_on_floor():
		velocity.y = velocity.y - (fall_acceleration * delta)
		
	move_and_slide()

func initialize():
	rotate_y(randf_range(-2 * PI, 2 * PI))
	var random_speed = randi_range(min_speed, max_speed)
	velocity = Vector3.FORWARD * random_speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)

#---------------READY FUNC-------------------------------
func _ready():
	sex = randomSex()
	morph = randomMorph()
	size = randomSize()
	male_mesh()

	set_body_color()
	set_lizard_size()
