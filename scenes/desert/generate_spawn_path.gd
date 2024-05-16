extends Path3D

func _on_desert_ready():
	var aabb_node = %Desert.get_aabb()
	var size_x = (%Desert.size[0] / 2) - 20
	var size_z = (%Desert.size[1] / 2) - 20
	print("size_x = ", size_x)
	print("size_y = ", size_z)
	print("position = ",aabb_node.position)
	print("end = ", aabb_node.end)
	self.curve.clear_points()
	self.curve.add_point(Vector3i(-size_x,0,-size_z))
	self.curve.add_point(Vector3i(-size_x, 0, size_z))
	self.curve.add_point(Vector3i(size_x, 0, size_z))
	self.curve.add_point(Vector3i(size_x, 0, -size_z))
	self.curve.add_point(Vector3i(-size_x,0,-size_z))

