class_name Simulation
extends Node

const EMPTY_ELEMENT: Element = preload("res://resources/elements/empty.tres")
const SAND_ELEMENT: Element = preload("res://resources/elements/sand.tres")
const WATER_ELEMENT: Element = preload("res://resources/elements/water.tres")
const WOOD_ELEMENT: Element = preload("res://resources/elements/wood.tres")

@export var simulation_visualizer: Sprite2D
@export var params: SimulationParams

var input_elements: Array[Element]
var output_elements: Array[Element]

var falling_sand_compute_shader: ComputeShader
var params_compute_buffer: ComputeBuffer
var input_elements_compute_buffer: ComputeBuffer
var output_elements_compute_buffer: ComputeBuffer

var simulation_image: Image
var paused: bool = false


func _ready():
	print("Starting simulation")
	setup_simulation()
	setup_compute_shader()
	update_visualization()


func _process(_delta: float) -> void:
	# Add brush
	if Input.is_action_pressed("add_element"): add_element()
	
	# Pause simulation
	if Input.is_action_just_pressed("simulation_toggle"): paused = not paused
	
	if not paused or Input.is_action_just_pressed("simulation_step"):
		dispatch_compute_shader()
		get_compute_data()
		update_visualization()
	
	# Cleanup the simulation
	if Input.is_action_just_pressed("ui_cancel"):
		print("Cleaning up compute shader")
		cleanup_compute_shader()
		await self.get_tree().create_timer(0.1).timeout
		self.get_tree().quit()


func setup_simulation() -> void:
	simulation_image = Image.create(params.width, params.height, false, Image.FORMAT_RGBAH)
	
	input_elements.resize(params.width * params.height)
	output_elements.resize(params.width * params.height)
	
	for i in params.width * params.height:
		input_elements[i] = EMPTY_ELEMENT
		output_elements[i] = EMPTY_ELEMENT


func setup_compute_shader() -> void:
	falling_sand_compute_shader = ComputeShader.from_file("res://shaders/compute/falling_sand.glsl")
	params_compute_buffer = falling_sand_compute_shader.create_compute_buffer(0, 0)
	input_elements_compute_buffer = falling_sand_compute_shader.create_compute_buffer(0, 1)
	output_elements_compute_buffer = falling_sand_compute_shader.create_compute_buffer(0, 2)


func dispatch_compute_shader() -> void:
	params.vertical_rand = randf()
	params.horizontal_rand = randf()
	
	params_compute_buffer.set_data(params)
	input_elements_compute_buffer.set_data(input_elements)
	output_elements_compute_buffer.set_data(output_elements)
	falling_sand_compute_shader.setup_pipeline(1, 1, 1)
	falling_sand_compute_shader.dispatch()
	falling_sand_compute_shader.sync()


func get_compute_data() -> void:
	input_elements.assign(output_elements_compute_buffer.get_data())


func cleanup_compute_shader() -> void:
	falling_sand_compute_shader.dispose([
		params_compute_buffer, 
		input_elements_compute_buffer, 
		output_elements_compute_buffer
	])


func add_element() -> void:
	var add_position: Vector2i = get_viewport().get_mouse_position() / simulation_visualizer.scale
	for i in [-1, 0, 1]:
		if add_position.x + i < 0 or add_position.x + i >= params.width: continue
		for j in [-1, 0, 1]:
			if add_position.y + j < 0 or add_position.y + j >= params.height: continue
			var add_id = (add_position.y + j) * params.width + (add_position.x + i)
			input_elements[add_id] = WOOD_ELEMENT;


func update_visualization() -> void:
	for x in params.width:
		for y in params.height:
			simulation_image.set_pixel(x, y, get_element_color(input_elements[y * params.width + x]))
	
	simulation_visualizer.texture = ImageTexture.create_from_image(simulation_image)


func get_element_color(element: Element) -> Color:
	match element.id:
		EMPTY_ELEMENT.id: return Color.TRANSPARENT
		SAND_ELEMENT.id:  return Color.BLANCHED_ALMOND
		WATER_ELEMENT.id: return Color.DARK_BLUE
		WOOD_ELEMENT.id:  return Color.SADDLE_BROWN
	return Color(0.0, 0.0, 0.0, 0.0)
