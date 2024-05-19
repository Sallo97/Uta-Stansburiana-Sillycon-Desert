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
@export var _start_button: Button


func _ready():
	_orange_percentage_slider.value = 100
	_start_button.pressed.connect(_start_simulation)


func _process(_delta):
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


func _start_simulation():
	SceneData.initialize({
		SceneData.Keys.DESERT_SIZE: Vector2i(int(_desert_heigth_spinbox.value), int(_desert_width_spinbox.value)),
		SceneData.Keys.LIZARD_COUNT: _lizard_count_spinbox.value,
		SceneData.Keys.ORANGE_PERCENTAGE: _orange_percentage_slider.value / 100.0,
		SceneData.Keys.BLUE_PERCENTAGE: _blue_percentage_slider.value / 100.0,
		SceneData.Keys.YELLOW_PERCENTAGE: _yellow_percentage_slider.value / 100.0
	})
	var desert_scene := preload("res://scenes/desert/desert.tscn").instantiate()
	get_tree().root.add_child(desert_scene)
	#call_deferred("free")
	hide()

