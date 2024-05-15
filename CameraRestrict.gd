extends Node

@export var min_height: float = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if %Camera3D.position.y < min_height:
		%Camera3D.position.y = min_height
