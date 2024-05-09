class_name Packer
extends Object


var _packer_type: GDScript
var _packer_stride: int
var _property_names: Array[String]
var _property_sizes: Array[int]
var _encode_function_names: Array[String]
var _decode_function_names: Array[String]
var _encoder: Encoder
var _decoder: Decoder


func _init(type: GDScript) -> void:
	_packer_type = type
	_packer_stride = Packing.sizeof_object(type)
	_property_names = Packing.get_property_names_array(type)
	_property_sizes = Packing.get_property_sizes_array(type)
	_encode_function_names = Packing.get_function_names(type, true)
	_decode_function_names = Packing.get_function_names(type, false)
	
	_encoder = Encoder.new()
	_encoder.set_script(_generate_encoder_script())
	
	_decoder = Decoder.new()
	_decoder.set_script(_generate_decoder_script())


func encode(object: Object) -> PackedByteArray:
	assert(object.get_script() == _packer_type)
	return _encoder.encode(object)


func encode_array(array: Array[Object]) -> PackedByteArray:
	var data: PackedByteArray = []
	for object: Object in array:
		data.append_array(encode(object))
	return data


func decode(data: PackedByteArray) -> Object:
	assert(data.size() % _packer_stride == 0) 
	return _decoder.decode(data, _packer_type)


func decode_array(data: PackedByteArray, count: int) -> Array[Object]:
	@warning_ignore("integer_division")
	assert(data.size() / _packer_stride == count)
	var objects: Array[Object] = []
	for i in count:
		objects.append(decode(data.slice(i * _packer_stride, (i + 1) * _packer_stride)))
	return objects


func get_packer_stride() -> int:
	return _packer_stride


func _generate_encoder_script() -> GDScript:
	var script_string: String = "extends Encoder\n"
	script_string += "func encode(object: Object) -> PackedByteArray:\n"
	script_string += "\tvar data: PackedByteArray = []\n"
	for i in _property_names.size():
		script_string += "\t" + _encode_function_names[i] + "(data, object." + str(_property_names[i]) + ")\n"
	script_string += "\treturn data"
	return _script_from_string(script_string)


func _generate_decoder_script() -> GDScript:
	var script_string: String = "extends Decoder\n"
	script_string += "func decode(data: PackedByteArray, type: GDScript) -> Object:\n"
	script_string += "\tvar object = type.new()\n"
	script_string += "\tvar byte_offset := 0\n"
	for i in _property_names.size():
		script_string += "\tobject." + str(_property_names[i]) + " = " + _decode_function_names[i] + "(data, byte_offset)\n"
		script_string += "\tbyte_offset += " + str(_property_sizes[i]) + "\n"
	script_string += "\treturn object"
	return _script_from_string(script_string)


func _script_from_string(script_string: String) -> GDScript:
	var script := GDScript.new()
	script.source_code = script_string
	script.reload()
	return script
