extends Node

@export var lizard_scene : PackedScene

func _on_spawn_timer_timeout():
	var lizard = lizard_scene.instantiate()
	var lizard_spawn_location = get_node("SpawnPath/SpawnLocation")
	lizard_spawn_location.progress_ratio = randf()
	lizard.initialize(lizard_spawn_location.position)
	add_child(lizard)
