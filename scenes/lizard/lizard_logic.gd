extends CharacterBody3D
class_name Lizard

#-------------SCRIPTS-----------------------------


#------------NODES---------------------------------
@onready var lizard_node : Node3D = get_node("Pivot/lizard")
@onready var animation_tree : AnimationTree = $AnimationTree

#-------------MESH NODES--------------------------
@onready var adult_lizard_mesh : MultiMeshInstance3D = %adult_lizard
@onready var baby_lizard_mesh : MultiMeshInstance3D = %baby_lizard

@onready var adult_body_node : MeshInstance3D = lizard_node.get_node("adult_lizard/Body")
@onready var adult_lips_node : MeshInstance3D = lizard_node.get_node("adult_lizard/Lips")
@onready var adult_ribbon_node : MeshInstance3D = lizard_node.get_node("adult_lizard/Ribbon")

@onready var baby_body_node : MeshInstance3D = %baby_lizard/Body
@onready var baby_lips_node : MeshInstance3D = %baby_lizard/Pacifier
@onready var baby_ribbon_node : MeshInstance3D = %baby_lizard/Ribbon

#--------VARIABLES--------------------------------

var sex: Constants.Sex #= Constants.Sex.FEMALE# = Constants.Sex.MALE
var morph:Constants.Morph # = Constants.Morph.ORANGE
var size: float = Constants.min_size
var alleles = [Constants.Allele.O, Constants.Allele.O]
var current_territories: Array[Territory] = []
var cell_change_timer: Timer
var speed:float
var destination_point
var direction 
var territory: Territory = null
#------------FLAGS-------------------------------
var is_adult:bool = true 
var falling: bool = true
var found_territory: bool = false
var pattern_step: int = 1
var behaviour_iterations: int = 0
var state: Constants.LizardState = Constants.LizardState.IDLE
var can_bounce: bool = true
var can_interact: bool = true
#-------------TIMER VARIABLES---------------------
var death_timer:Timer
var lifetime: float
var grow_up_timer:Timer
var grow_up_time:float

#---------CONSTRUCTORS-------------------------
func set_lizard_prob(prob_sex:float = 0.5, prob_orange:float = 1/3.0,
		   prob_yellow:float = 1/3.0, prob_blue:float = 1/3.0):
	# print("prob_sex = ", prob_sex)
	sex = randomSex(prob_sex)
	# sex = Constants.Sex.MALE
	# print("sex = ", sex)
	morph = randomMorph(sex, prob_orange,
						prob_blue, prob_yellow)
	alleles = Constants.set_random_alleles(morph,prob_orange,
								 prob_blue, prob_yellow)
	main_settings()

func set_lizard_fixed(new_sex:Constants.Sex, new_morph:Constants.Morph):
	sex = new_sex
	morph = new_morph
	alleles = Constants.set_random_alleles(morph)
	main_settings()
	
func set_lizard_child(papa:Lizard, mama:Lizard):
	sex = randomSex()
	alleles = Constants.set_alleles(sex, papa.alleles, mama.alleles)
	morph = Constants.Alleles_Comb.ret_morph(alleles)
	# if morph == Constants.Morph.YELLOW:
	# 	print_debug("Yellow child born!")
	self.global_position = ((papa.global_position + mama.global_position)/2) + (Vector3.UP * 10)
	is_adult = false
	set_grow_up_timer()
	main_settings()	

func main_settings():
	floor_constant_speed = true
	floor_max_angle = (PI / 2.1)
	set_mesh()
	set_body_color()
	size = Lizard.randomSize(sex, morph)
	set_lizard_size()
	update_animation_parameters(0)
	@warning_ignore("narrowing_conversion")
	lifetime = int(float(randi_range(Constants.min_lifetime, Constants.max_lifetime)) * (0.6 if morph == Constants.Morph.ORANGE else 1.0) * SceneData.get_lifespan_multiplier(1.0))
	@warning_ignore("narrowing_conversion")
	speed = randi_range(Constants.min_speed, Constants.max_speed)
	set_death_timer()


#---------SETTING FUNC--------------------

# It chooses randomly the sex of the lizard.
# Getting a male or a female is equiprobable
static func randomSex(prob:float = 0.5):
	# return Constants.Sex.MALE
	var is_male : bool = randf() <= prob 
	if is_male:
		return Constants.Sex.MALE
	else:
		return Constants.Sex.FEMALE


# It chooses randomly the morph of the lizard.
# all the colors are equiprobable
static func randomMorph(sex:Constants.Sex, or_prob=0.5,
						bl_prob=0.5, yw_prob=0.5):
	
	# Setting probabilities
	var morph
	var rand_val = randf()
	match sex:
		Constants.Sex.MALE:
			if rand_val <= or_prob:
				return Constants.Morph.ORANGE
			if rand_val <= or_prob + bl_prob:
				return Constants.Morph.BLUE
			else:
				return Constants.Morph.YELLOW
		Constants.Sex.FEMALE:
			if rand_val <= or_prob:
				return Constants.Morph.ORANGE
			else:
				return Constants.Morph.YELLOW

# It chooses randomly the size of the lizard.
# baseSize = [20…30]mm
# size = baseSize + (male ? 10 : 0) + (orange ? 10 : 0))
# size cannot be > 60
static func randomSize(sex:Constants.Sex, morph:Constants.Morph) -> float:
	var baseSize: float = randf_range(Constants.min_size, Constants.max_size) 
	if(sex == Constants.Sex.MALE):
		baseSize += 0.1
	if (morph == Constants.Morph.ORANGE):
		baseSize += 0.10
	if (baseSize > 0.60):
		baseSize = 0.60
	return baseSize
	
func set_death_timer():
	death_timer = Timer.new()
	death_timer.autostart = true
	death_timer.one_shot = true
	death_timer.wait_time = lifetime
	self.add_child(death_timer)
	death_timer.start()
	death_timer.timeout.connect(play_death_animation) 
	
func set_grow_up_timer():
	grow_up_timer = Timer.new()
	grow_up_timer.autostart = true
	grow_up_timer.one_shot = true
	grow_up_time = randf_range(Constants.min_grow_up_timer, Constants.max_grow_up_timer) 
	grow_up_timer.wait_time = grow_up_time
	self.add_child(grow_up_timer)
	grow_up_timer.start()
	grow_up_timer.timeout.connect(becoming_adult)


#--------------MODIFY MESH FUNC------------

# This function sets the color of the body 
# ONLY on THIS instance of the lizard
func set_body_color():
	var material = StandardMaterial3D.new()
	material.albedo_color = Constants.Color_Values.ret_color(morph)
	adult_body_node.material_override = material
	baby_body_node.material_override = material

# This function sets the size of ONLY
# THIS instance of the lizard
func set_lizard_size():
	var scale_value: float = float(size) # 1 : 20 = scale_value : size 
	if !is_adult:
		scale_value *= 0.5
	scale_object_local( Vector3(scale_value,scale_value,scale_value) )
	

# This function removes the ribbon and the lips from the mesh
# if the current lizard is male
func set_female_attribute():
	if (sex == Constants.Sex.MALE):
		adult_lips_node.hide()
		adult_ribbon_node.hide()
		baby_ribbon_node.hide()
		baby_lips_node.hide()
	else:
		adult_lips_node.show()
		adult_ribbon_node.show()
		baby_ribbon_node.show()
		baby_lips_node.show()
		
func set_adult_mesh():
	adult_lizard_mesh.show()
	baby_lizard_mesh.hide()
	
func set_child_mesh():
	baby_lizard_mesh.show()
	adult_lizard_mesh.hide()

func set_mesh():
	if(is_adult):
		set_adult_mesh()
	else:
		set_child_mesh()
	set_female_attribute()
	
func becoming_adult():
	is_adult = true
	remove_from_group("Children")
	add_to_group("Lizards")
	set_mesh()
	scale_object_local( Vector3(2,2,2) )
	set_state(Constants.LizardState.IDLE)

func turn_blue():
	morph = Constants.Morph.BLUE
	alleles = Constants.Alleles_Comb.blue_comb[0]
	set_body_color()
	set_state(Constants.LizardState.IDLE)

#------------INITIALIZE FUNC----------------------------------------
func initialize(other_lizard:Lizard = null):
	if other_lizard == null:
		rotate_y(randf_range(0, 2 * PI))
	else:
		# print("other_lizard.position = ", other_lizard.position)
		look_at_from_position(self.position, other_lizard.position, Vector3.UP)
	

#---------------API FUNC-------------------------------

func _on_area_3d_body_entered(body):
	if(is_adult and body != self and body.is_in_group("Lizards") && can_interact && body.can_interact): #
		InteractionManager.start_interaction(self, body)

func _physics_process(delta):
	if !is_inside_tree():
		return

	if position.y < -100:
		LizardPool.instance().despawn(self)
		print(self, " fell off! Despawning")
		return

	# print_debug(state)
	match state:
		Constants.LizardState.IDLE:
			# Decide action

			match is_adult:
				false:
					set_state(Constants.LizardState.WANDERING)
				true:
					match sex:
						Constants.Sex.MALE:
							match morph:
								Constants.Morph.ORANGE, Constants.Morph.BLUE when territory == null:
									set_state(Constants.LizardState.SEARCHING)
								Constants.Morph.ORANGE, Constants.Morph.BLUE when territory != null:
									set_state(Constants.LizardState.PATROLLING)
								Constants.Morph.YELLOW:
									set_state(Constants.LizardState.WANDERING)
						Constants.Sex.FEMALE:
							if territory == null || territory.is_queued_for_deletion():
								set_state(Constants.LizardState.WANDERING)
							else:
								set_state(Constants.LizardState.PATROLLING)
				

		Constants.LizardState.SEARCHING when can_move():
			hill_climb_pattern()

		Constants.LizardState.WANDERING when can_move():
			wander_pattern()

		Constants.LizardState.PATROLLING when can_move():
			patrol_own_territory()

		Constants.LizardState.ATTACKING_INTRUDER when can_move():
			attack_intruder()

		Constants.LizardState.CREATING_TERRITORY:
			create_territory()
	
	# Apply gravity
	velocity.y = velocity.y - (Constants.fall_acceleration * delta)
	
	# Clamp velocity to the max allowed velocity to avoid lizards shooting away into the void
	if velocity.length() > Constants.max_velocity:
		velocity = velocity.normalized() * Constants.max_velocity
	
		
	if !is_on_floor() || !can_move() : #and raycast.is_colliding()
		stop_velocity()
		
	if is_on_wall() && can_bounce:
		if destination_point is Vector3:
			can_bounce = false
			destination_point = destination_point.bounce(get_wall_normal().normalized())
			var dest: Vector3 = destination_point
			dest.y = position.y
			look_at_from_position(global_position, dest)
			var bounce_timer := Timer.new()
			bounce_timer.autostart = false
			bounce_timer.one_shot = true
			bounce_timer.wait_time = 0.2
			bounce_timer.timeout.connect(func ():
				can_bounce = true
				bounce_timer.queue_free())
			add_child(bounce_timer)
			bounce_timer.start()
			# rotate(Vector3.UP, PI / 2.0)
			# velocity = velocity.rotated(Vector3.UP, PI / 2.0)
			
	var coll := get_last_slide_collision()
	if coll != null && coll.get_collision_count() > 0 && coll.get_collider(0) is Lizard:
		self.position += Vector3.FORWARD.rotated(Vector3.UP, randf_range(-PI, PI))

	move_and_slide()
	
func _ready():
	animation_tree.active = true
	

func normal_velocity():
	velocity = Vector3.FORWARD * speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	

func on_other_lizard_entered_territory(other: Lizard):
	if !other.is_adult || !can_interact:
		return
	if state == Constants.LizardState.PATROLLING && other.sex == Constants.Sex.MALE:
		if other.morph == Constants.Morph.YELLOW:
			match morph:
				Constants.Morph.ORANGE when randf() > 0.7: # Probability that a yellow lizard enters unnoticed
					return
				# Constants.Morph.BLUE when randf() > 0.8:
				# 	return
		set_state(Constants.LizardState.ATTACKING_INTRUDER)
		destination_point = other


func on_entered_territory(territory: Territory):
	if !is_adult:
		return
	if (sex == Constants.Sex.FEMALE || morph == Constants.Morph.YELLOW) && state == Constants.LizardState.WANDERING:
		if territory.owner_lizard.morph == Constants.Morph.BLUE && territory.females.size() > 0:
			return
		self.territory = territory
		if !territory.females.has(self):
			territory.females.push_back(self)
		set_state(Constants.LizardState.PATROLLING)

#-----------ANIMATIONS FUNC-------------------

func update_animation_parameters(animation:int): 	# 0 = idle
													# 1 = attacking
													# 2 = cuddling
													# 3 = death
	if (animation==0):										
		animation_tree["parameters/conditions/is_idle"] = true
		animation_tree["parameters/conditions/is_attacking"] = false
		animation_tree["parameters/conditions/is_cuddling"] = false
		animation_tree["parameters/conditions/is_dead"] = false
	elif (animation==1):
		animation_tree["parameters/conditions/is_attacking"] = true
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_cuddling"] = false
		animation_tree["parameters/conditions/is_dead"] = false
	
	elif (animation==2):
		animation_tree["parameters/conditions/is_cuddling"] = true
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_attacking"] = false
		animation_tree["parameters/conditions/is_dead"] = false
	
	elif (animation==3):
		animation_tree["parameters/conditions/is_dead"] = true
		animation_tree["parameters/conditions/is_cuddling"] = false
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_attacking"] = false
		
func play_death_animation():
	set_state(Constants.LizardState.STOPPED)
	var animation_timer = Timer.new()
	animation_timer.autostart = true
	animation_timer.one_shot = true
	animation_timer.wait_time = 1
	self.add_child(animation_timer)
	animation_timer.start()
	update_animation_parameters(3)
	animation_timer.timeout.connect(LizardPool.instance().despawn.bind(self)) 


#-------------MOVEMENT FUNC--------------------
# 1 - Dal pt in cui mi trovo determino il punto piu' alto
# 2 - Mi giro nella dirzione di destination_point (delegato a look_at_from_position)
# 3 - Mi muovo verso quella direzione, fermandomi quando arrivo (delegato a arrive_at_point)
# 4 - Impostalo come territorio di quella lucertola
func hill_climb_pattern():
	match (pattern_step):
		0:
			return
		1:
			hill_climb_pattern_1()
		2:
			hill_climb_pattern_2()
		3:
			hill_climb_pattern_3()
		#4:
			


func hill_climb_pattern_1():
	# STEP 1 - Dal pt in cui mi trovo determino il punto piu' alto
	var current_cell = DistanceCalculator.instance().get_cell_at_position(self.global_position)
	if !DistanceCalculator.instance().is_valid_cell(current_cell):
		return
	var ret_array = DistanceCalculator.instance().max_height_in_circle_approx(current_cell, 5)
	var absolute_position = DistanceCalculator.instance().get_position_of_cell(ret_array[0])

	#print_debug(DistanceCalculator.instance().get_cell_at_position(position))
	#print_debug(DistanceCalculator.instance().get_cell_at_position(DistanceCalculator.instance().get_position_of_cell(DistanceCalculator.instance().get_cell_at_position(position))))

	destination_point = Vector3(absolute_position[0], global_position.y, absolute_position[2])
	pattern_step = 2
	
func hill_climb_pattern_2():
	# STEP 2 - Mi giro nella direzione di destination_point
	look_at_from_position(self.global_position, destination_point)
	pattern_step = 3
	speed = 20

	var timer: Timer = Timer.new()
	timer.autostart = false
	timer.one_shot = false
	timer.wait_time = 0.5
	timer.timeout.connect(func ():
		if state == Constants.LizardState.SEARCHING:
			pattern_step = 1
			behaviour_iterations -= 1
			# print_debug(behaviour_iterations)
			if behaviour_iterations == 0:
				# print_debug("Stopped max iterations")
				set_state(Constants.LizardState.CREATING_TERRITORY)
		timer.queue_free())
	add_child(timer)
	timer.start()

func hill_climb_pattern_3():
	# print("destination_point = ", destination_point)
	# print("self.position = ", self.position)
	# look_at_from_position(self.position, destination_point)
	direction = global_position.direction_to(destination_point)
	velocity = direction * speed
	velocity.y = 0
	velocity += (Vector3.DOWN * velocity.y)
	# STEP 3 - Mi muovo verso destination_point, mi fermo quando lo raggiungo
	# Dentro l'if sarebbe meglio dire che se la distanza tra self.position e' higher point e' 
	# dentro un certo range, si ferma
	if(abs(self.global_position.x - destination_point.x) < 0.001 && abs(self.global_position.z - destination_point.z) < 0.001):
		# print_debug("Stopped: ", abs(self.global_position.x - destination_point.x), ", ", abs(self.global_position.z - destination_point.z))
		set_state(Constants.LizardState.CREATING_TERRITORY)

	pattern_step = 3
	

func stop_velocity():
	velocity.x = 0
	velocity.z = 0


func can_move():
	match state:
		Constants.LizardState.IDLE, Constants.LizardState.STOPPED, Constants.LizardState.FIGHTING, Constants.LizardState.LOVING:
			return false
		_:  return is_on_floor()


func set_state(new_state: Constants.LizardState):
	pattern_step = 1
	state = new_state
	match new_state:
		Constants.LizardState.SEARCHING:
			match morph:
				Constants.Morph.ORANGE:
					behaviour_iterations = Constants.orange_hill_iterations
				Constants.Morph.BLUE:
					behaviour_iterations = Constants.blue_hill_iterations
				_: assert(false) # IMPOSSIBLE!!!


func wander_pattern():
	match (pattern_step):
		0:
			return
		1:
			wander_pattern_1()
		2:
			wander_pattern_2()
		#4:


func wander_pattern_1():
	# STEP 1 - Get random point in radius
	destination_point = global_position.direction_to(global_transform * Vector3.FORWARD).rotated(Vector3.UP, randf_range(-PI / 3.0, PI + 3.0))
	look_at_from_position(self.global_position, self.global_position + destination_point)
	speed = 20

	var timer: Timer = Timer.new()
	timer.autostart = false
	timer.one_shot = false
	timer.wait_time = 3
	timer.timeout.connect(func ():
		if state == Constants.LizardState.WANDERING:
			pattern_step = 1
		timer.queue_free())
	add_child(timer)
	timer.start()

	pattern_step = 2
	
func wander_pattern_2():
	direction = destination_point
	velocity = direction * speed
	velocity.y = 0
	velocity += (Vector3.DOWN * velocity.y)


func create_territory():
	# print_debug("Creating territory!")
	territory = Grid.instance().create_territory(self)
	set_state(Constants.LizardState.IDLE)


func patrol_own_territory():
	match (pattern_step):
		0:
			return
		1:
			patrol_own_territory1()
		2:
			patrol_own_territory2()
		#4:

func patrol_own_territory1():
	if territory == null || territory.is_queued_for_deletion():
		set_state(Constants.LizardState.IDLE)
		return
	# STEP 1 - Get random point in territory
	destination_point = DistanceCalculator.instance().get_position_of_cell(territory.cells.pick_random())
	destination_point.y = global_position.y
	look_at_from_position(self.global_position, destination_point)
	speed = 10

	var timer: Timer = Timer.new()
	timer.autostart = false
	timer.one_shot = false
	timer.wait_time = 1
	timer.timeout.connect(func ():
		if state == Constants.LizardState.PATROLLING:
			pattern_step = 1
		timer.queue_free())
	add_child(timer)
	timer.start()

	pattern_step = 2

func patrol_own_territory2():
	if territory == null || territory.is_queued_for_deletion():
		set_state(Constants.LizardState.IDLE)
		return
	direction = global_position.direction_to(destination_point)
	velocity = direction * speed
	velocity.y = 0
	velocity += (Vector3.DOWN * velocity.y)



func attack_intruder():
	match (pattern_step):
		0:
			return
		1:
			attack_intruder1()
		2:
			attack_intruder2()
		#4:

func attack_intruder1():
	if destination_point == null || destination_point.is_queued_for_deletion():
		destination_point = null
		set_state(Constants.LizardState.IDLE)
		return
	var destination = destination_point.global_position
	destination.y = global_position.y
	look_at_from_position(self.global_position, destination)
	speed = 20

	var timer: Timer = Timer.new()
	timer.autostart = false
	timer.one_shot = false
	timer.wait_time = 1
	timer.timeout.connect(func ():
		if state == Constants.LizardState.ATTACKING_INTRUDER:
			pattern_step = 1
		timer.queue_free())
	add_child(timer)
	timer.start()

	pattern_step = 2

func attack_intruder2():
	if destination_point == null || destination_point.is_queued_for_deletion() || !is_inside_tree():
		destination_point = null
		set_state(Constants.LizardState.IDLE)
		return
	var destination = destination_point.global_position
	destination.y = global_position.y
	look_at_from_position(self.global_position, destination)
	direction = global_position.direction_to(destination)
	velocity = direction * speed
	velocity.y = 0
	velocity += (Vector3.DOWN * velocity.y)
