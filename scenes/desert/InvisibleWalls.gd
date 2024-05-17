extends StaticBody3D
@onready var aabb_node = %Desert.get_aabb()

func _ready():
	generate_walls()

# This function generate invisible walls around the desert.
# This is done in order to avoid that the lizard fall off
func generate_walls():
	var offset_y = 100
	var min_x : float = aabb_node.position.x - 30 # hotfix to avoid that at the edge-vertices 
												  # a lizard can fall off
	var min_y : float = aabb_node.position.y - offset_y
	var min_z : float = aabb_node.position.z
	var max_x : float = aabb_node.end.x + 30	  # same hotfix
	var max_y : float = aabb_node.end.y + offset_y
	var max_z : float = aabb_node.position.z 
	
	 # First Wall
	var p1 : Vector3 = Vector3(max_x, min_y, min_z)
	var p2 : Vector3 = Vector3(max_x, min_y, max_z)
	var p3 : Vector3 = Vector3(max_x, max_y, min_z)
	var p4 : Vector3 = Vector3(max_x, max_y, max_z)


	var shape_1 = ConvexPolygonShape3D.new()
	shape_1.points = PackedVector3Array([p1,p2,p3,p4,p1,p2,p3,p4])
	var wall_1 : CollisionShape3D = CollisionShape3D.new()
	wall_1.shape = shape_1

	 # Second Wall
	p1 = Vector3(max_x, min_y, max_z)
	p2 = Vector3(min_x, min_y, max_z)
	p3 = Vector3(max_x, max_y, max_z)
	p4 = Vector3(min_x, max_y, max_z)

	
	var shape_2 = ConvexPolygonShape3D.new()
	shape_2.points = PackedVector3Array([p1,p2,p3,p4,p1,p2,p3,p4])
	var wall_2 : CollisionShape3D = CollisionShape3D.new()
	wall_2.shape = shape_2
	
	 # Third Wall
	p1 = Vector3(min_x, min_y, max_z)
	p2 = Vector3(min_x, min_y, min_z)
	p3 = Vector3(min_x, max_y, max_z)
	p4 = Vector3(min_x, max_y, min_z)



	var shape_3 = ConvexPolygonShape3D.new()
	shape_3.points = PackedVector3Array([p1,p2,p3,p4,p1,p2,p3,p4])
	var wall_3 : CollisionShape3D = CollisionShape3D.new()
	wall_3.shape = shape_3

	 # Fourth Wall 
	p1 = Vector3(max_x, min_y, min_z)
	p2 = Vector3(min_x, min_y, min_z)
	p3 = Vector3(max_x, max_y, min_z)
	p4 = Vector3(min_x, max_y, min_z)


	var shape_4 = ConvexPolygonShape3D.new()
	shape_4.points = PackedVector3Array([p1,p2,p3,p4,p1,p2,p3,p4])
	var wall_4 : CollisionShape3D = CollisionShape3D.new()
	wall_4.shape = shape_4

	add_child(wall_1)
	add_child(wall_2)
	add_child(wall_3)
	add_child(wall_4)
