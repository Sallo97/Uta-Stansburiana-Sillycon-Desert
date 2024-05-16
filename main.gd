extends Node

@export var lizard_scene : PackedScene

@onready var spawnPath_node : Path3D = get_node("SpawnPath")

# Every time the timer ticks it instantiate a new lizard
func _on_spawn_timer_timeout():
	var lizard = lizard_scene.instantiate()
	lizard.position = get_random_position()
	lizard.initialize()
	add_child(lizard)

# Returns a random position within the Path3D
func get_random_position() -> Vector3:
	var curve : Curve3D = spawnPath_node.curve
	var path_length = curve.get_baked_length()
	var offset = randf_range(0.0, path_length)
	var result_path_position = curve.sample_baked(offset)
	var result = spawnPath_node.to_local(result_path_position)
	result.y = 0.0
	return result


