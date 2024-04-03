class_name ComputeShader
extends Object

signal dispatched()
signal synced()

var rendering_device: RenderingDevice
var shader_file: RDShaderFile
var shader_spirv: RDShaderSPIRV
var shader: RID
var compute_list: int
var pipeline: RID
var uniform_sets: Dictionary
var first_dispatch: bool = true

var _pipeline_setup: bool = false


static func from_file(path: String) -> ComputeShader:
	var cs := ComputeShader.new()
	
	# Create rendering device
	cs.rendering_device = RenderingServer.create_local_rendering_device()
	
	# Load shader
	cs.shader_file = load(path)
	cs.shader_spirv = cs.shader_file.get_spirv()
	cs.shader = cs.rendering_device.shader_create_from_spirv(cs.shader_spirv)
	
	return cs


func create_compute_buffer(binding_index: int, set_index: int) -> ComputeBuffer:
	var cb := ComputeBuffer.new(self, binding_index)
	_add_uniform_to_set(cb.uniform, set_index)
	return cb


func setup_pipeline(x_groups: int, y_groups: int, z_groups: int) -> void:
	# Define the compute pipeline
	pipeline = rendering_device.compute_pipeline_create(shader)
	compute_list = rendering_device.compute_list_begin()
	rendering_device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	for set_index in uniform_sets:
		var uniform_set := rendering_device.uniform_set_create(uniform_sets[set_index], shader, set_index)
		rendering_device.compute_list_bind_uniform_set(compute_list, uniform_set, set_index)
	rendering_device.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
	rendering_device.compute_list_end()
	_pipeline_setup = true


func dispatch() -> void:
	if not _pipeline_setup:
		printerr("Attempting to dispatch ComputeShader without a pipeline setup. " \
		+ "Please call setup_pipeline on the ComputeShader first.")
	
	rendering_device.submit()
	dispatched.emit()


func sync() -> void:
	rendering_device.sync()
	synced.emit()


func _add_uniform_to_set(uniform: RDUniform, set_index: int) -> void:
	if uniform_sets.has(set_index):
		uniform_sets[set_index].append(uniform)
	else:
		uniform_sets[set_index] = [uniform]