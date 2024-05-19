extends Node

@export var lizard_scene : PackedScene
@onready var aabb_node = %Desert.get_aabb()

#-------------GLOBAL VARIABLES-------------------------
var num_lizard:int = 100
var prob_orange:float = 0.5
var prob_blue:float = 0.5
var prob_yellow:float = 0.5
var prob_sex:float = 0.5

@onready var group_lizards
var lizard_interacting := []

# Every time the timer ticks it instantiate a new lizard
func _on_timer_timeout():
	group_lizards = get_tree().get_nodes_in_group("Lizards")
	# print("number of lizards = ",group_lizards.size())
	if num_lizard > 0:
		var new_liz:Lizard = lizard_scene.instantiate()
		set_lizard(new_liz)
		num_lizard -= 1
		
func set_lizard(liz:Lizard):
	
	liz.set_lizard_prob(prob_sex, prob_orange,
			  	   prob_yellow, prob_blue)
	liz.position = sample_point()
	add_child(liz)
	Graphs.lizard_spawned(liz)
	%Grid.create_territory(liz)
	
	
	

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
	
# In reads from the menu all the values
# regarning num of lizards and probability of morph
#func get_from_menu():
	#num_lizard = get_num_lizards()
	#prob_orange = get_prob_orange()
	#prob_blue = get_prob_blue()
	#prob_yellow = get_prob_yellow()
