extends Node

@export var elements: Array[Element]


func _ready() -> void:
	var compute_shader := ComputeShader.from_file("res://tests/compute_api_test/compute_api_test.glsl")
	
	var elements_buffer := compute_shader.create_compute_buffer(0, 0)
	elements_buffer.set_data(elements)
	
	compute_shader.setup_pipeline(1, 1, 1)
	compute_shader.dispatch()
	compute_shader.sync()
	
	var output_data: Array[Element] = []
	output_data.assign(elements_buffer.get_data())
	
	for element in output_data:
		print("Element")
		print(element.id)
		print(element.density)
		print(element.flamability)
		print()
