extends Node

var _lizards: Array[int] = [0, 0, 0]

# Called when the node enters the scene tree for the first time.
func _ready():
	DebugDraw2D.set_text("FPS", Engine.get_frames_per_second())
	var graph_orange: DebugDraw2DGraph = DebugDraw2D.create_graph("Orange Lizards")
	graph_orange.data_getter = _datagetter_orange
	var graph_blue: DebugDraw2DGraph = DebugDraw2D.create_graph("Blue Lizards")
	graph_blue.data_getter = _datagetter_blue
	var graph_yellow: DebugDraw2DGraph = DebugDraw2D.create_graph("Yellow Lizards")
	graph_yellow.data_getter = _datagetter_yellow


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _datagetter_orange() -> float:
	return _lizards[0]
	
func _datagetter_blue() -> float:
	return _lizards[1]
	
func _datagetter_yellow() -> float:
	return _lizards[2]

func lizard_spawned(lizard):
	match lizard.morph:
		Constants.Morph.ORANGE:
			_lizards[0] += 1
		Constants.Morph.BLUE:
			_lizards[1] += 1			
		Constants.Morph.YELLOW:
			_lizards[2] += 1			
