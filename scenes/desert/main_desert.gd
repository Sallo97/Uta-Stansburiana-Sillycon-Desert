extends Node

@export var lizard_scene : PackedScene

@onready var spawnPath_node : Path3D = get_node("SpawnPath")

# Every time the timer ticks it instantiate a new lizard
func _on_timer_timeout():
	var lizard = lizard_scene.instantiate()
	lizard.position = sample_point()
	lizard.initialize()
	add_child(lizard)
	Graphs.lizard_spawned(lizard)
	%Grid.create_territory(lizard)
	#print("nuova lucertola generata")

# Returns a random point within the generated mesh.
# A lizard will always spawn from the sky, thus
# the y-coordinate is a constant
func sample_point() -> Vector3:

	# Get the size of the desert	
	var aabb_node = %Desert.get_aabb()
	# -border_offset is done in order to prevent that the lizard falls off
	const border_offset = 20

	var min_x = aabb_node.position.x + border_offset
	var min_z = aabb_node.position.z + border_offset

	var max_x = aabb_node.end.x - border_offset
	var max_z = aabb_node.end.z - border_offset

	var point_y = aabb_node.end.y + 5

	var point_x = randi_range(min_x, max_x) 
	var point_z = randi_range(min_z, max_z)
	
	# print("generating lizard at x = ", point_x, " z = ", point_z)
	return Vector3(point_x, point_y, point_z)

func _ready():
	#print("main_desert è stato caricato yuppi!!")
	pass


func _on_area_3d_body_entered(body):
	print("ho colliso con qualcosa") 
