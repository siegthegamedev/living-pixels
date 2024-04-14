class_name Simulation
extends Node

const EMPTY_ELEMENT: Element = preload("res://resources/elements/empty.tres")
const SAND_ELEMENT: Element = preload("res://resources/elements/sand.tres")

@export var params: SimulationParams

var elements: Array[Element]
var output_elements: Array[Element]


func _ready():
	elements.resize(params.widht * params.height)
	output_elements.resize(params.widht * params.height)
	
	for i in params.widht * params.height:
		elements[i] = EMPTY_ELEMENT
		output_elements[i] = EMPTY_ELEMENT
	elements[3] = SAND_ELEMENT
	
	var compute_shader := ComputeShader.from_file("res://shaders/compute/falling_sand.glsl")
	var params_buffer := compute_shader.create_compute_buffer(0, 0)
	var grid_buffer := compute_shader.create_compute_buffer(0, 1)
	var output_grid_buffer := compute_shader.create_compute_buffer(0, 2)
	
	params_buffer.set_data(params)
	grid_buffer.set_data(elements)
	output_grid_buffer.set_data(output_elements)
	
	compute_shader.setup_pipeline(1, 1, 1)
	compute_shader.dispatch()
	compute_shader.sync()
	
	var output: Array[Element] = []
	output.assign(output_grid_buffer.get_data())
	
	var i: int = 0
	for element: Element in output:
		print(i)
		print(element.id)
		print()
		i += 1
