class_name ComputeBuffer
extends Object

var rendering_device: RenderingDevice
var data_bytes: PackedByteArray
var buffer: RID
var uniform: RDUniform

var _data_set: bool = false
var _buffer_size: int = -1
var _buffer_type: GDScript = null


func _init(compute_shader: ComputeShader, binding_index: int) -> void:
	compute_shader.dispatched.connect(_on_shader_dispatch)
	compute_shader.synced.connect(_on_shader_sync)
	
	rendering_device = compute_shader.rendering_device
	uniform = RDUniform.new()
	uniform.uniform_type =  RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = binding_index


func set_data(data: Variant) -> void:
	data = data if data is Array else [data]
	_buffer_size = data.size()
	_buffer_type = data[0].get_script()
	data_bytes = Packing.encode_objects(data)
	set_bytes(data_bytes)


func set_bytes(data: PackedByteArray) -> void:
	if _data_set:
		rendering_device.free_rid(buffer)
	
	buffer = rendering_device.storage_buffer_create(data.size(), data)
	uniform.clear_ids()
	uniform.add_id(buffer)
	_data_set = true


func update_bytes(data: PackedByteArray) -> void:
	rendering_device.buffer_update(buffer, 0, data.size(), data)


func get_data() -> Array:
	var output_bytes := rendering_device.buffer_get_data(buffer)
	return Packing.decode_objects(output_bytes, _buffer_type, _buffer_size)


func get_bytes() -> PackedByteArray:
	return rendering_device.buffer_get_data(buffer)


func dispose() -> void:
	rendering_device.free_rid(buffer)


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
