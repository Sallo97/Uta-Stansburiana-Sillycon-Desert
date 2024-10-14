extends Control

@export var _desert_width_spinbox: SpinBox
@export var _desert_heigth_spinbox: SpinBox
@export var _lizard_count_spinbox: SpinBox
@export var _orange_percentage_label: Label
@export var _orange_percentage_slider: Slider
@export var _blue_percentage_label: Label
@export var _blue_percentage_slider: Slider
@export var _yellow_percentage_label: Label
@export var _yellow_percentage_slider: Slider

@export var _lifespan_slider: Slider
@export var _lifespan_label: Label

@export var _territory_size_slider: Slider
@export var _territory_size_label: Label

@export var _mesh_subdivision_slider: Slider
@export var _mesh_subdivision_label: Label

@export var _start_button: Button

var desert_scene: Node


func _ready():
	_orange_percentage_slider.value = 100
	_blue_percentage_slider.value = 100
	_yellow_percentage_slider.value = 100
	_start_button.pressed.connect(_start_simulation)


func _process(_delta):
	if Input.is_action_just_pressed("main_menu") && desert_scene != null:
		# get_tree().root.remove_child(desert_scene)
		desert_scene.queue_free()
		desert_scene = null
		Graphs.destroy()

		show()

	var slider_sum := _orange_percentage_slider.value + _blue_percentage_slider.value + _yellow_percentage_slider.value
	if slider_sum == 0:
		_orange_percentage_slider.value = 1
		_orange_percentage_slider.min_value = 1
	else:
		_orange_percentage_slider.min_value = 0
		var max_perc: float = float(100) / float(slider_sum)
		_orange_percentage_label.text = "{p}%".format({"p": int(_orange_percentage_slider.value * max_perc)})
		_blue_percentage_label.text = "{p}%".format({"p": int(_blue_percentage_slider.value * max_perc)})
		_yellow_percentage_label.text = "{p}%".format({"p": int(_yellow_percentage_slider.value * max_perc)})

	_lifespan_label.text = "{p}".format({"p": _lifespan_slider.value})
	_territory_size_label.text = "{p}".format({"p": _territory_size_slider.value})

	if _desert_heigth_spinbox.value <= 0:
		_desert_heigth_spinbox.value = 100
	if _desert_width_spinbox.value <= 0:
		_desert_heigth_spinbox.value = 100
	_mesh_subdivision_label.text = "{p}".format({"p": _mesh_subdivision_slider.value})


func _start_simulation():
	if desert_scene != null:
		return
	var slider_sum := _orange_percentage_slider.value + _blue_percentage_slider.value + _yellow_percentage_slider.value
	SceneData.initialize({
		SceneData.Keys.DESERT_SIZE: Vector2i(int(_desert_heigth_spinbox.value), int(_desert_width_spinbox.value)),
		SceneData.Keys.LIZARD_COUNT: _lizard_count_spinbox.value,
		SceneData.Keys.ORANGE_PERCENTAGE: _orange_percentage_slider.value / slider_sum,
		SceneData.Keys.BLUE_PERCENTAGE: _blue_percentage_slider.value / slider_sum,
		SceneData.Keys.YELLOW_PERCENTAGE: _yellow_percentage_slider.value / slider_sum,
		SceneData.Keys.MESH_SUBDIVISION: _mesh_subdivision_slider.value,
		SceneData.Keys.LIFESPAN_MULTIPLIER: _lifespan_slider.value,
		SceneData.Keys.TERRITORY_SIZE_MULTIPLIER: _territory_size_slider.value
	})
	desert_scene = load("res://scenes/desert/desert.tscn").instantiate()
	get_tree().root.add_child(desert_scene)
	#call_deferred("free")
	hide()

