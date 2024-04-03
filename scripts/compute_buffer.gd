class_name ComputeBuffer
extends Object

var rendering_device: RenderingDevice
var data_bytes: PackedByteArray
var buffer: RID
var uniform: RDUniform

var _data_set: bool = false


func _init(compute_shader: ComputeShader, binding_index: int) -> void:
	compute_shader.dispatched.connect(_on_shader_dispatch)
	compute_shader.synced.connect(_on_shader_sync)
	
	rendering_device = compute_shader.rendering_device
	uniform = RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = binding_index


func set_data(data: Array) -> void:
	data_bytes = Packing.encode_array(data)
	buffer = rendering_device.storage_buffer_create(data_bytes.size(), data_bytes)
	uniform.clear_ids()
	uniform.add_id(buffer)
	_data_set = true


func get_data(type: Object, count: int) -> Array:
	var output_bytes := rendering_device.buffer_get_data(buffer)
	return Packing.decode_array(output_bytes, type, count)


func _on_shader_dispatch() -> void:
	if not _data_set:
		printerr("Attempting to dispatch ComputeShader without setting data on the ComputeBuffer. "
		+ "Call set_data on the ComputeBuffer first.")
		breakpoint


func _on_shader_sync() -> void:
	if not _data_set:
		printerr("Attempting to sync the ComputeShader without setting data on the ComputeBuffer. "
		+ "Call set_data on the ComputeBuffer first.")
		breakpoint
