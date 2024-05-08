class_name ComputeShader
extends Object

signal dispatched()
signal synced()

var rendering_device: RenderingDevice

var _stages: Array[RID]
var _pipelines: Array[RID]
var _uniforms_dict: Dictionary
var _uniform_sets: Array = []
var _buffers_to_dispose: Array[ComputeBuffer] = []
var _textures_to_dispose: Array[ComputeTexture] = []


static func from_file(path: String) -> ComputeShader:
	var cs := ComputeShader.new()
	cs.add_stage_from_file(path)
	return cs


func _init() -> void:
	rendering_device = RenderingServer.create_local_rendering_device()


func create_compute_buffer(set_index: int, binding_index: int) -> ComputeBuffer:
	var cb := ComputeBuffer.new(self, binding_index)
	_add_uniform_to_set(cb.uniform, set_index)
	return cb


func create_compute_texture(binding_index: int, texture_format: RDTextureFormat) -> ComputeTexture:
	var ct := ComputeTexture.new(self, binding_index, texture_format)
	_add_uniform_to_set(ct.uniform, 0)
	return ct 


func add_stage_from_file(path: String) -> void:
	var file := load(path)
	var spirv = file.get_spirv()
	_stages.push_back(rendering_device.shader_create_from_spirv(spirv))


func setup() -> void:
	# Create all uniform sets for each shader stage
	for i in _stages.size():
		for set_index in _uniforms_dict:
			var uniform_set := rendering_device.uniform_set_create(_uniforms_dict[set_index], _stages[i], set_index)
			_uniform_sets.append([uniform_set, set_index])
	
	# Create a compute pipeline for each shader stage
	for stage: RID in _stages:
		_pipelines.push_back(rendering_device.compute_pipeline_create(stage))


func dispatch(x_groups: int, y_groups: int, z_groups: int) -> void:
	var compute_list := rendering_device.compute_list_begin()
	for uniform_set in _uniform_sets:
		rendering_device.compute_list_bind_uniform_set(compute_list, uniform_set[0], uniform_set[1])
	for pipeline: RID in _pipelines:
		rendering_device.compute_list_bind_compute_pipeline(compute_list, pipeline)
		rendering_device.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
		rendering_device.compute_list_add_barrier(compute_list)
	rendering_device.compute_list_end()
	
	#rendering_device.submit()
	dispatched.emit()


func sync() -> void:
	rendering_device.sync()
	synced.emit()


func dispose() -> void:
	_free_uniform_sets()
	for buffer: ComputeBuffer in _buffers_to_dispose:
		buffer.dispose()
	for texture: ComputeTexture in _textures_to_dispose:
		texture.dispose()
	for pipeline: RID in _pipelines:
		rendering_device.free_rid(pipeline)
	for stage: RID in _stages:
		rendering_device.free_rid(stage)
	rendering_device.free()


func _add_uniform_to_set(uniform: RDUniform, set_index: int) -> void:
	if _uniforms_dict.has(set_index):
		_uniforms_dict[set_index].append(uniform)
	else:
		_uniforms_dict[set_index] = [uniform]


func _free_uniform_sets() -> void:
	for uniform_set in _uniform_sets:
		if not rendering_device.uniform_set_is_valid(uniform_set): continue
		rendering_device.free_rid(uniform_set)
	_uniforms_dict.clear()
