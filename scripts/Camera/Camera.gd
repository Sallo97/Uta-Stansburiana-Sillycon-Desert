extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	look_at(Vector3(0, 0, 0), Vector3(0, 0, 1))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
