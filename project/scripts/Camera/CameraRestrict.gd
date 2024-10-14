extends Node

@export var min_height: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var aabb: AABB = %Desert.get_aabb()
	if %Camera3D.position.y < aabb.end.y + min_height:
		%Camera3D.position.y = aabb.end.y + min_height

	if %Camera3D.position.x < aabb.position.x:
		%Camera3D.position.x = aabb.position.x
	elif %Camera3D.position.x > aabb.end.x:
		%Camera3D.position.x = aabb.end.x
	
	if %Camera3D.position.z < aabb.position.z:
		%Camera3D.position.z = aabb.position.z
	elif %Camera3D.position.z > aabb.end.z:
		%Camera3D.position.z = aabb.end.z
