extends Node

@export var lizard_scene : PackedScene
@onready var aabb_node = %Deh.get_aabb()
@onready var spawnPath_node : Path3D = get_node("SpawnPath")

# Every time the timer ticks it instantiate a new lizard
func _on_spawn_timer_timeout():
	#generate_walls()
	var lizard = lizard_scene.instantiate()
	lizard.position = sample_point()
	lizard.initialize()
	add_child(lizard)

# Returns a random position within the Path3D
func sample_point() -> Vector3:

	# Get the size of the desert	
	var max_x = absf(aabb_node.position.x) - 20  # -20 is done in order
	var max_z = absf(aabb_node.position.z) - 20  # to prevent that the lizard
	var max_y = absf(aabb_node.position.y) + 50  # falls off

	var point_x = randi_range(-max_x, max_x) 
	var point_z = randi_range(-max_z, max_z)
	
	# print("generating lizard at x = ", point_x, " z = ", point_z)
	return Vector3(point_x, max_y, point_z)
	
#func generate_walls():
	#print("Generating walls...")
	#var offset_y = 100
	#var min_x : float = aabb_node.position.x
	#var min_y : float = aabb_node.position.y - offset_y
	#var min_z : float = aabb_node.position.z
	#var max_x : float = aabb_node.end.x
	#var max_y : float = aabb_node.end.y + offset_y
	#var max_z : float = aabb_node.end.z  # Assuming end.z represents the max z-coordinate
#
	## Create the walls
	#create_wall(Vector3(max_x, min_y, min_z), Vector3(max_x - 20, min_y, min_z - 20), Vector3(max_x, max_y, min_z), Vector3(max_x, max_y, min_z - 20))  # First Wall
	#create_wall(Vector3(max_x, min_y, max_z), Vector3(max_x - 20, min_y, max_z - 20), Vector3(max_x, max_y, max_z), Vector3(max_x, max_y, max_z - 20))  # Second Wall
	#create_wall(Vector3(min_x, min_y, max_z), Vector3(min_x - 20, min_y, max_z - 20), Vector3(min_x, max_y, max_z), Vector3(min_x, max_y, max_z - 20))  # Third Wall
	#create_wall(Vector3(min_x, min_y, min_z), Vector3(min_x - 20, min_y, min_z - 20), Vector3(min_x, max_y, min_z), Vector3(min_x, max_y, min_z - 20))  # Fourth Wall
#
#func create_wall(p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3):
	#var shape = ConvexPolygonShape3D.new()
	#shape.points = PackedVector3Array([p1, p2, p3, p4])
	#var collision_shape = CollisionShape3D.new()
	#collision_shape.shape = shape
#
	#var wall_body = StaticBody3D.new()
	#wall_body.add_child(collision_shape)
	#add_child(wall_body)

