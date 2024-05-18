extends Node

@export var lizard_scene : PackedScene
@onready var aabb_node = %Desert.get_aabb()

#-------------GLOBAL VARIABLES-------------------------
var count_lizard = 2 # will set the number of lizard that will spanw
@onready var group_lizards
var lizard_interacting := []

# Every time the timer ticks it instantiate a new lizard
func _on_timer_timeout():
	group_lizards = get_tree().get_nodes_in_group("Lizards")
	# print("number of lizards = ",group_lizards.size())
	if count_lizard > 0:
		var lizard = lizard_scene.instantiate()
		lizard.position = sample_point()

		if group_lizards.size() > 0:
			# print("Sono qui")
			var random_idx = randi_range(0, group_lizards.size() - 1)
			lizard.initialize(group_lizards[0])
		else:
			lizard.initialize()	
		add_child(lizard)
		lizard.add_to_group("Lizards")
		Graphs.lizard_spawned(lizard)
		%Grid.create_territory(lizard)
		#print("nuova lucertola generata")
		count_lizard -= 1

# Returns a random point within the generated mesh.
# A lizard will always spawn from the sky, thus
# the y-coordinate is a constant
func sample_point() -> Vector3:
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

func _on_area_3d_body_entered(body):
	body.queue_free()
	print(body, " fell off!, I removed it")
