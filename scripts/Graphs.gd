extends Node

const BUFFER_SIZE = 5000

var _lizards: Array[int] = [0, 0, 0]
var _graphs_visible: bool = false
var _graph: DebugDraw2DGraph
var _graph_orange: DebugDraw2DGraph
var _graph_blue: DebugDraw2DGraph
var _graph_yellow: DebugDraw2DGraph
var _frame_graph: DebugDraw2DFPSGraph

# Called when the node enters the scene tree for the first time.
func _ready():
	_graph = DebugDraw2D.create_graph("Lizards")
	_graph.data_getter = _datagetter_total
	_graph.line_color = Color.GAINSBORO
	_graph.buffer_size = BUFFER_SIZE	
	_graph.show_title = true
	
	_graph_orange = DebugDraw2D.create_graph("Orange")
	_graph_orange.data_getter = _datagetter_orange
	_graph_orange.show_title = true
	_graph_orange.line_color = Constants.Color_Values.orange_color
	_graph_orange.buffer_size = BUFFER_SIZE
	_graph_orange.set_parent(_graph.get_title(), DebugDraw2DGraph.SIDE_BOTTOM)
	
	_graph_blue = DebugDraw2D.create_graph("Blue")
	_graph_blue.data_getter = _datagetter_blue
	_graph_blue.show_title = true
	_graph_blue.line_color = Constants.Color_Values.blue_color
	_graph_blue.buffer_size = BUFFER_SIZE	
	_graph_blue.set_parent(_graph_orange.get_title(), DebugDraw2DGraph.SIDE_BOTTOM)
	
	_graph_yellow = DebugDraw2D.create_graph("Yellow")
	_graph_yellow.data_getter = _datagetter_yellow
	_graph_yellow.show_title = true
	_graph_yellow.line_color = Constants.Color_Values.yellow_color	
	_graph_yellow.buffer_size = BUFFER_SIZE	
	_graph_yellow.set_parent(_graph_blue.get_title(), DebugDraw2DGraph.SIDE_BOTTOM)
	
	_frame_graph = DebugDraw2D.create_fps_graph("Frame Timings")
	_frame_graph.show_title = true
	_frame_graph.corner = DebugDraw2DGraph.POSITION_LEFT_BOTTOM
	
	_toggle_graph_visibility()
	_toggle_graph_visibility()

func _process(_delta):
	if _graphs_visible:
		DebugDraw2D.set_text("FPS", Engine.get_frames_per_second())
	if Input.is_action_just_pressed("graph_toggle"):
		_toggle_graph_visibility()

func _toggle_graph_visibility() -> void:
	_graphs_visible = !_graphs_visible
	_graph.enabled = _graphs_visible
	_graph_orange.enabled = _graphs_visible
	_graph_blue.enabled = _graphs_visible
	_graph_yellow.enabled = _graphs_visible
	_frame_graph.enabled = _graphs_visible 

func _datagetter_total() -> float:
	return _lizards[0] + _lizards[1] + _lizards[2]
	
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
