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
var _uniform_sets: Array[RID] = []


static func from_file(path: String) -> ComputeShader:
	var cs := ComputeShader.new()
	
	# Create rendering device
	cs.rendering_device = RenderingServer.create_local_rendering_device()
	
	# Load shader
	cs.shader_file = load(path)
	cs.shader_spirv = cs.shader_file.get_spirv()
	cs.shader = cs.rendering_device.shader_create_from_spirv(cs.shader_spirv)
	
	return cs


func create_compute_buffer(set_index: int, binding_index: int) -> ComputeBuffer:
	var cb := ComputeBuffer.new(self, binding_index)
	_add_uniform_to_set(cb.uniform, set_index)
	return cb


func create_compute_texture(binding_index: int, texture_format: RDTextureFormat) -> ComputeTexture:
	var ct := ComputeTexture.new(self, binding_index, texture_format)
	_add_uniform_to_set(ct.uniform, 0)
	return ct 


func setup_pipeline(x_groups: int, y_groups: int, z_groups: int) -> void:
	if _pipeline_setup:
		rendering_device.free_rid(pipeline)
	
	pipeline = rendering_device.compute_pipeline_create(shader)
	compute_list = rendering_device.compute_list_begin()
	rendering_device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	for set_index in uniform_sets:
		var uniform_set := rendering_device.uniform_set_create(uniform_sets[set_index], shader, set_index)
		rendering_device.compute_list_bind_uniform_set(compute_list, uniform_set, set_index)
		_uniform_sets.append(uniform_set)
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


func dispose(buffers_to_dispose: Array[ComputeBuffer], textures_to_dispose: Array[ComputeTexture]) -> void:
	_free_uniform_sets()
	for buffer: ComputeBuffer in buffers_to_dispose:
		buffer.dispose()
	for texture: ComputeTexture in textures_to_dispose:
		texture.dispose()
	rendering_device.free_rid(pipeline)
	rendering_device.free_rid(shader)
	rendering_device.free()


func _add_uniform_to_set(uniform: RDUniform, set_index: int) -> void:
	if uniform_sets.has(set_index):
		uniform_sets[set_index].append(uniform)
	else:
		uniform_sets[set_index] = [uniform]


func _free_uniform_sets() -> void:
	for uniform_set in _uniform_sets:
		if not rendering_device.uniform_set_is_valid(uniform_set): continue
		rendering_device.free_rid(uniform_set)
	uniform_sets.clear()
