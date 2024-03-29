class_name Packing
extends Object


static func sizeof(type: Object) -> int:
	var size: int = 0
	for property in type.new().get_property_list():
		var property_type: int = property["type"]
		var property_usage: int = property["usage"]
		if not (property_usage & PROPERTY_USAGE_SCRIPT_VARIABLE): continue
		if not (property_usage & PROPERTY_USAGE_EDITOR): continue
		match property_type:
			TYPE_FLOAT:
				size += 4
			TYPE_INT:
				size += 4
	return size


static func encode(object: Object) -> PackedByteArray:
	var packed_array := PackedByteArray()
	for property in object.get_property_list():
		var property_name: String = property["name"]
		var property_type: int = property["type"]
		var property_usage: int = property["usage"]
		if not (property_usage & PROPERTY_USAGE_SCRIPT_VARIABLE): continue
		if not (property_usage & PROPERTY_USAGE_EDITOR): continue
		match property_type:
			TYPE_FLOAT:
				encode_float(packed_array, object[property_name])
			TYPE_INT:
				encode_int(packed_array, object[property_name])
	return packed_array


static func decode(packed_array: PackedByteArray, type: Object) -> Object:
	var decoded_object: Object = type.new()
	var byte_offset: int = 0
	for property in decoded_object.get_property_list():
		var property_name: String = property["name"]
		var property_type: int = property["type"]
		var property_usage: int = property["usage"]
		if not (property_usage & PROPERTY_USAGE_SCRIPT_VARIABLE): continue
		if not (property_usage & PROPERTY_USAGE_EDITOR): continue
		match property_type:
			TYPE_FLOAT:
				decoded_object[property_name] = decode_float(packed_array, byte_offset)
				byte_offset += 4
			TYPE_INT:
				decoded_object[property_name] = decode_int(packed_array, byte_offset)
				byte_offset += 4
	return decoded_object


static func decode_array(packed_array: PackedByteArray, type: Object, count: int) -> Array[Object]:
	var type_size = sizeof(type)
	var decoded_objects: Array[Object] = []
	for i in count:
		var slice_begin: int = i * type_size
		var slice_end: int = slice_begin + type_size
		decoded_objects.append(decode(packed_array.slice(slice_begin, slice_end), type))
	return decoded_objects


static func encode_int(packed_array: PackedByteArray, value: int) -> void:
	packed_array.append_array(PackedInt32Array([value]).to_byte_array())


static func encode_ints(packed_array: PackedByteArray, values: Array[int]) -> void:
	packed_array.append_array(PackedInt32Array(values).to_byte_array())


static func decode_int(packed_array: PackedByteArray, byte_offset: int) -> int:
	return packed_array.decode_s32(byte_offset)


static func encode_float(packed_array: PackedByteArray, value: float) -> void:
	packed_array.append_array(PackedFloat32Array([value]).to_byte_array())


static func encode_floats(packed_array: PackedByteArray, values: Array[float]) -> void:
	packed_array.append_array(PackedFloat32Array(values).to_byte_array())


static func decode_float(packed_array: PackedByteArray, byte_offset: int) -> float:
	return packed_array.decode_float(byte_offset)
