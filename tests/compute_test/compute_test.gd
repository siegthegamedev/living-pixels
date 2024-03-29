extends Node


func _ready():
	# Create rendering device
	var rendering_device := RenderingServer.create_local_rendering_device()
	
	# Load shader
	var shader_file: RDShaderFile = load("res://tests/compute_test/compute_example.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	var shader := rendering_device.shader_create_from_spirv(shader_spirv)

	# Prepare input buffer
	var input := PackedFloat32Array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
	var input_bytes := input.to_byte_array()
	var buffer := rendering_device.storage_buffer_create(input_bytes.size(), input_bytes)
	
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
	rendering_device.compute_list_dispatch(compute_list, 5, 1, 1)
	rendering_device.compute_list_end()
	
	# Execute the compute shader
	rendering_device.submit()
	rendering_device.sync() # Ideally, you would wait some 2 or 3 frames to sync the GPU with the GPU so that they can work in parallel
	
	# Retrieve the results of the computation
	var output_bytes := rendering_device.buffer_get_data(buffer)
	var output := output_bytes.to_float32_array()
	print("Input: ", input)
	print("Output: ", output)
