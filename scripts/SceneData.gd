extends Node

var _is_initialized: bool = false
var _desert_size: Vector2i = Vector2i(300, 300)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_desert_size(default: Vector2i) -> Vector2i:
	if !_is_initialized:
		return default
	else:
		return _desert_size

func initialize(data: Variant) -> void:
	_is_initialized = true
	_desert_size = data["desert_size"]
