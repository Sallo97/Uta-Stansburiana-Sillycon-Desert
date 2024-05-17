extends Node

@export var lizard_scene : PackedScene

@onready var spawnPath_node : Path3D = get_node("SpawnPath")

# Every time the timer ticks it instantiate a new lizard
func _on_timer_timeout():
	var lizard = lizard_scene.instantiate()
	lizard.position = sample_point()
	lizard.initialize()
	add_child(lizard)
	#print("nuova lucertola generata")

# Returns a random point within the generated mesh.
# A lizard will always spawn from the sky, thus
# the y-coordinate is a constant
func sample_point() -> Vector3:

	# Get the size of the desert	
	var aabb_node = %Desert.get_aabb()
	var max_x = absf(aabb_node.position.x) - 20  # -20 is done in order
	var max_z = absf(aabb_node.position.z) - 20  # to prevent that the lizard
	var max_y = absf(aabb_node.position.y) + 50  # falls off

	var point_x = randi_range(-max_x, max_x) 
	var point_z = randi_range(-max_z, max_z)
	
	# print("generating lizard at x = ", point_x, " z = ", point_z)
	return Vector3(point_x, max_y, point_z)

func _ready():
	#print("main_desert è stato caricato yuppi!!")
	pass


func _on_area_3d_body_entered(body):
	print("ho colliso con qualcosa") 
