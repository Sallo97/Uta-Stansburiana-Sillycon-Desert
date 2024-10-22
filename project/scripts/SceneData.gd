extends Node

var _is_initialized: bool = false
var _data: Variant = {}

enum Keys {
	DESERT_SIZE,
	LIZARD_COUNT,
	ORANGE_PERCENTAGE,
	BLUE_PERCENTAGE,
	YELLOW_PERCENTAGE,
	MESH_SUBDIVISION,
	LIFESPAN_MULTIPLIER,
	TERRITORY_SIZE_MULTIPLIER
}


func __get(property, default):
	if !_is_initialized:
		return default
	else:
		return _data.get(property, default)


func initialize(data: Variant) -> void:
	_is_initialized = true
	_data = data


func get_desert_size(default: Vector2i) -> Vector2i:
	return __get(Keys.DESERT_SIZE, default)

func get_lizard_count(default: int) -> int:
	return __get(Keys.LIZARD_COUNT, default)

func get_orange_probability(default: float) -> float:
	return __get(Keys.ORANGE_PERCENTAGE, default)

func get_blue_probability(default: float) -> float:
	return __get(Keys.BLUE_PERCENTAGE, default)

func get_yellow_probability(default: float) -> float:
	return __get(Keys.YELLOW_PERCENTAGE, default)

func get_mesh_subdivision(default: int) -> int:
	return __get(Keys.MESH_SUBDIVISION, default)

func get_lifespan_multiplier(default: float) -> float:
	return __get(Keys.LIFESPAN_MULTIPLIER, default)

func get_territory_multiplier(default: float) -> float:
	return __get(Keys.TERRITORY_SIZE_MULTIPLIER, default)
