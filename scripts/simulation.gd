class_name Simulation
extends Node

@export var elements: Array[Element]


func _ready():
	# Create rendering device
	var rendering_device := RenderingServer.create_local_rendering_device()
	
	# Load shader
	var shader_file: RDShaderFile = load("res://shaders/compute/falling_sand.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	var shader := rendering_device.shader_create_from_spirv(shader_spirv)

	# Prepare input buffer
	var input := Packing.encode_array(elements)
	var buffer := rendering_device.storage_buffer_create(input.size(), input)
	
	# Bind the input buffer to the compute shader
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0 # This needs to match the binding on the shader
	uniform.add_id(buffer)
	var uniform_set := rendering_device.uniform_set_create([uniform], shader, 0) # This last parameter needs to match the set on the shader
	
	# Define the compute pipeline
	var pipeline := rendering_device.compute_pipeline_create(shader)
	var compute_list := rendering_device.compute_list_begin()
	rendering_device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rendering_device.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rendering_device.compute_list_dispatch(compute_list, 1, 1, 1)
	rendering_device.compute_list_end()
	
	# Execute the compute shader
	rendering_device.submit()
	rendering_device.sync() # Ideally, you would wait some 2 or 3 frames to sync the GPU with the GPU so that they can work in parallel
	
	# Retrieve the results of the computation
	var output_bytes := rendering_device.buffer_get_data(buffer)
	print("input size: " + str(input.size()))
	print("output size: " + str(output_bytes.size()))
	print("element size: " + str(Packing.sizeof(Element)))
	print()
	var output: Array[Element] = []
	output.assign(Packing.decode_array(output_bytes, Element, elements.size()))
	
	print(input)
	print(output_bytes)
	print()
	
	for element in output:
		print(element.id)
		print(element.density)
		print(element.flamability)
		print()
