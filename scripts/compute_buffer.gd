class_name ComputeBuffer
extends Object

var rendering_device: RenderingDevice
var buffer: RID
var uniform: RDUniform

var _packer: Packer
var _data_bytes: PackedByteArray = []
var _buffer_count: int = -1
var _buffer_type: GDScript = null


func _init(compute_shader: ComputeShader, binding_index: int, count: int, type: GDScript) -> void:
	compute_shader.dispatched.connect(_on_shader_dispatch)
	compute_shader.synced.connect(_on_shader_sync)
	
	_packer = Packer.new(type)
	_buffer_count = count
	_buffer_type = type
	_data_bytes.resize(count * Packing.sizeof_object(type))
	
	rendering_device = compute_shader.rendering_device
	uniform = RDUniform.new()
	uniform.uniform_type =  RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = binding_index
	
	buffer = rendering_device.storage_buffer_create(_data_bytes.size(), _data_bytes)
	uniform.add_id(buffer)


func set_data(data: Variant) -> void:
	data = data if data is Array else [data]
	assert(data.size() == _buffer_count)
	assert(data[0].get_script() == _buffer_type)
	set_bytes(_packer.encode_array(data))


func set_bytes(data: PackedByteArray) -> void:
	assert(data.size() == Packing.sizeof_object(_buffer_type) * _buffer_count)
	
	rendering_device.buffer_update(buffer, 0, data.size(), data)


func get_data() -> Array:
	var output_bytes := rendering_device.buffer_get_data(buffer)
	return Packing.decode_objects(output_bytes, _buffer_type, _buffer_count)


func get_bytes() -> PackedByteArray:
	return rendering_device.buffer_get_data(buffer)


func dispose() -> void:
	rendering_device.free_rid(buffer)


func _on_shader_dispatch() -> void:
	pass


func _on_shader_sync() -> void:
	pass
