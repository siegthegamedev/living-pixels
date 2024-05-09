class_name Packer
extends Object

var encode_type: GDScript
var type_size: int
var property_names: Array[String]
var property_sizes: Array[int]
var encode_function_names: Array[String]
var decode_function_names: Array[String]

var _encoder: Encoder
var _decoder: Decoder


func _init(type: GDScript) -> void:
	encode_type = type
	type_size = Packing.sizeof_object(type)
	property_names = Packing.get_property_names_array(type)
	property_sizes = Packing.get_property_sizes_array(type)
	encode_function_names = Packing.get_function_names(type, true)
	decode_function_names = Packing.get_function_names(type, false)
	
	_encoder = Encoder.new()
	_encoder.set_script(_generate_encoder_script())
	
	_decoder = Decoder.new()
	_decoder.set_script(_generate_decoder_script())


func encode(object: Object) -> PackedByteArray:
	assert(object.get_script() == encode_type)
	return _encoder.encode(object)


func encode_array(array: Array[Object]) -> PackedByteArray:
	var data: PackedByteArray = []
	for object: Object in array:
		data.append_array(encode(object))
	return data


func decode(data: PackedByteArray) -> Object:
	assert(data.size() % type_size == 0) 
	return _decoder.decode(data, encode_type)


func get_type_size() -> int:
	return type_size


func _generate_encoder_script() -> GDScript:
	var script_string: String = "extends Encoder\n"
	script_string += "func encode(object: Object) -> PackedByteArray:\n"
	script_string += "\tvar data: PackedByteArray = []\n"
	for i in property_names.size():
		script_string += "\t" + encode_function_names[i] + "(data, object." + str(property_names[i]) + ")\n"
	script_string += "\treturn data"
	return _script_from_string(script_string)


func _generate_decoder_script() -> GDScript:
	var script_string: String = "extends Decoder\n"
	script_string += "func decode(data: PackedByteArray, type: GDScript) -> Object:\n"
	script_string += "\tvar object = type.new()\n"
	script_string += "\tvar byte_offset := 0\n"
	for i in property_names.size():
		script_string += "\tobject." + str(property_names[i]) + " = " + decode_function_names[i] + "(data, byte_offset)\n"
		script_string += "\tbyte_offset += " + str(property_sizes[i]) + "\n"
	script_string += "\treturn object"
	return _script_from_string(script_string)


func _script_from_string(script_string: String) -> GDScript:
	var script := GDScript.new()
	script.source_code = script_string
	script.reload()
	return script
