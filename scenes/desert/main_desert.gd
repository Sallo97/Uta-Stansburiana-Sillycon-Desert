extends Node

@export var lizard_scene : PackedScene

@onready var spawnPath_node : Path3D = get_node("SpawnPath")

# Every time the timer ticks it instantiate a new lizard
func _on_timer_timeout():
	var lizard = lizard_scene.instantiate()
	lizard.position = get_random_position()
	lizard.initialize()
	add_child(lizard)
	#print("nuova lucertola generata")

# Returns a random position within the Path3D
func get_random_position() -> Vector3:
	var curve : Curve3D = spawnPath_node.curve
	var path_length = curve.get_baked_length()
	var offset = randf_range(0.0, path_length)
	var result_path_position = curve.sample_baked(offset)
	var result = spawnPath_node.to_local(result_path_position)
	result.y = 50.0
	return result

func _ready():
	#print("main_desert è stato caricato yuppi!!")
	pass


func _on_area_3d_body_entered(body):
	print("ho colliso con qualcosa") 
