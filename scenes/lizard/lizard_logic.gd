extends CharacterBody3D
class_name Lizard
#-----------SCRIPTS--------------------
var constants_scpt = preload("res://scenes/lizard/constants.gd")

#------------NODES---------------------------------
@onready var lizard_node : Node3D = get_node("Pivot/lizard")
@onready var body_node : MeshInstance3D = lizard_node.get_node("Body")
@onready var lips_node : MeshInstance3D = lizard_node.get_node("Lips")
@onready var ribbon_node : MeshInstance3D = lizard_node.get_node("Ribbon")


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
		constants_scpt.Sex.MALE:
			rand = randi_range(0,2)
		constants_scpt.Sex.FEMALE:
			rand = randi_range(0,1)
	return rand

# It chooses randomly the size of the lizard.
# baseSize = [20…30]mm
# size = baseSize + (male ? 10 : 0) + (orange ? 10 : 0))
# size cannot be > 60
func randomSize():
	var baseSize : int = randi_range(Constants.min_size, Constants.max_size) 
	if(sex == constants_scpt.Sex.MALE):
		baseSize += 10
	if (morph == constants_scpt.Morph.ORANGE):
		baseSize += 10
	if (baseSize > 60):
		baseSize = 60
	return baseSize

#--------------MODIFY MESH FUNC------------

# This function sets the color of the body 
# ONLY on THIS instance of the lizard
func set_body_color():
	var material = StandardMaterial3D.new()
	material.albedo_color = constants_scpt.Color_Values.ret_color(morph)
	body_node.material_override = material

# This function sets the size of the ONLY
# THIS instance of the lizard
func set_lizard_size():
	var scale_value : float = float(size) / float(Constants.min_size) # 1 : 20 = scale_value : size 
	lizard_node.global_scale( Vector3(scale_value,scale_value,scale_value) )

# This function removes the ribbon and the lips from the mesh
# if the current lizard is male
func male_mesh():
	if (sex == constants_scpt.Sex.MALE) :
		lips_node.hide()
		ribbon_node.hide()

#------------MOVEMENT FUNC----------------------------------------

func _physics_process(delta):
	if not is_on_floor():
		velocity.y = velocity.y - (Constants.fall_acceleration * delta)
		
	move_and_slide()

func initialize(other_lizard:Lizard = null):
	if other_lizard == null:
		rotate_y(randf_range(-2 * PI, 2 * PI))
	else:
		look_at_from_position(self.position, other_lizard.position, Vector3.UP)
	

#---------------READY FUNC-------------------------------
func _ready():
	sex = Constants.Sex.MALE #remember to change it into randomSex()
	morph = randomMorph()
	size = randomSize()
	male_mesh()
	set_body_color()
	set_lizard_size()
	change_velocity_state()
	self.add_to_group("Lizards")
	

func _process(delta: float) -> void:
	var raycast = $RayCast3D
	if falling and raycast.is_colliding():
		falling = false
		change_velocity_state()
		
func change_velocity_state():
	if falling == true:
		velocity.x = 0
		velocity.z = 0
	else:
		velocity = Vector3.FORWARD * randi_range(Constants.min_speed, Constants.max_speed)
		velocity = velocity.rotated(Vector3.UP, rotation.y)
		



func _on_area_3d_body_entered(body):
	if(body != self and body.is_in_group("Lizards")):
		%LizardInteracting.start_interaction(self, body)
