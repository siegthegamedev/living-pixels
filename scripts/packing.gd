class_name Packing
extends Object

const SIZEOF_INT: int = 4
const SIZEOF_FLOAT: int = 4
const SIZEOF_BOOL: int = 4
const SIZEOF_VECTOR2: int = 2 * SIZEOF_FLOAT
const SIZEOF_VECTOR2I: int = 2 * SIZEOF_INT


static func sizeof_object(type: GDScript) -> int:
	var size: int = 0
	for property in type.get_script_property_list():
		var property_type: int = property["type"]
		var property_usage: int = property["usage"]
		if not (property_usage & PROPERTY_USAGE_SCRIPT_VARIABLE): continue
		if not (property_usage & PROPERTY_USAGE_EDITOR): continue
		match property_type:
			TYPE_BOOL:
				size += SIZEOF_BOOL
			TYPE_INT:
				size += SIZEOF_INT
			TYPE_FLOAT:
				size += SIZEOF_FLOAT
			TYPE_VECTOR2:
				size += SIZEOF_VECTOR2
			TYPE_VECTOR2I:
				size += SIZEOF_VECTOR2I
	return size


static func encode_object(object: Object) -> PackedByteArray:
	var packed_array := PackedByteArray()
	for property in object.get_script().get_script_property_list():
		var property_name: String = property["name"]
		var property_type: int = property["type"]
		var property_usage: int = property["usage"]
		if not (property_usage & PROPERTY_USAGE_SCRIPT_VARIABLE): continue
		if not (property_usage & PROPERTY_USAGE_EDITOR): continue
		match property_type:
			TYPE_BOOL:
				encode_bool(packed_array, object[property_name])
			TYPE_INT:
				encode_int(packed_array, object[property_name])
			TYPE_FLOAT:
				encode_float(packed_array, object[property_name])
			TYPE_VECTOR2:
				encode_vector2(packed_array, object[property_name])
			TYPE_VECTOR2I:
				encode_vector2i(packed_array, object[property_name])
	return packed_array


static func encode_objects(objects: Array) -> PackedByteArray:
	var packed_array := PackedByteArray()
	for object in objects:
		packed_array.append_array(encode_object(object))
	return packed_array


static func decode_object(packed_array: PackedByteArray, type: GDScript) -> Object:
	var decoded_object: Object = type.new()
	var byte_offset: int = 0
	for property in type.get_script_property_list():
		var property_name: String = property["name"]
		var property_type: int = property["type"]
		var property_usage: int = property["usage"]
		if not (property_usage & PROPERTY_USAGE_SCRIPT_VARIABLE): continue
		if not (property_usage & PROPERTY_USAGE_EDITOR): continue
		match property_type:
			TYPE_BOOL:
				decoded_object[property_name] = decode_bool(packed_array, byte_offset)
				byte_offset += SIZEOF_BOOL
			TYPE_INT:
				decoded_object[property_name] = decode_int(packed_array, byte_offset)
				byte_offset += SIZEOF_FLOAT
			TYPE_FLOAT:
				decoded_object[property_name] = decode_float(packed_array, byte_offset)
				byte_offset += SIZEOF_FLOAT
			TYPE_VECTOR2:
				decoded_object[property_name] = decode_vector2(packed_array, byte_offset)
				byte_offset += SIZEOF_VECTOR2
			TYPE_VECTOR2I:
				decoded_object[property_name] = decode_vector2i(packed_array, byte_offset)
				byte_offset += SIZEOF_VECTOR2I
	return decoded_object


static func decode_objects(packed_array: PackedByteArray, type: Object, count: int) -> Array:
	var type_size = sizeof_object(type)
	var decoded_objects := []
	for i in count:
		var slice_begin: int = i * type_size
		var slice_end: int = slice_begin + type_size
		decoded_objects.append(decode_object(packed_array.slice(slice_begin, slice_end), type))
	return decoded_objects


static func encode_bool(packed_array: PackedByteArray, value: bool) -> void:
	packed_array.append_array(PackedInt32Array([1 if value else 0]).to_byte_array())


static func encode_int(packed_array: PackedByteArray, value: int) -> void:
	packed_array.append_array(PackedInt32Array([value]).to_byte_array())


static func encode_float(packed_array: PackedByteArray, value: float) -> void:
	packed_array.append_array(PackedFloat32Array([value]).to_byte_array())


static func encode_vector2(packed_array: PackedByteArray, value: Vector2) -> void:
	packed_array.append_array(PackedFloat32Array([value.x, value.y]).to_byte_array())


static func encode_vector2i(packed_array: PackedByteArray, value: Vector2i) -> void:
	packed_array.append_array(PackedInt32Array([value.x, value.y]).to_byte_array())


static func decode_bool(packed_array: PackedByteArray, byte_offset: int) -> bool:
	return packed_array.decode_u32(byte_offset) == 1


static func decode_int(packed_array: PackedByteArray, byte_offset: int) -> int:
	return packed_array.decode_s32(byte_offset)


static func decode_float(packed_array: PackedByteArray, byte_offset: int) -> float:
	return packed_array.decode_float(byte_offset)


static func decode_vector2(packed_array: PackedByteArray, byte_offset: int) -> Vector2:
	var x := packed_array.decode_float(byte_offset)
	var y := packed_array.decode_float(byte_offset + SIZEOF_FLOAT)
	return Vector2(x, y)


static func decode_vector2i(packed_array: PackedByteArray, byte_offset: int) -> Vector2i:
	var x := packed_array.decode_s32(byte_offset)
	var y := packed_array.decode_s32(byte_offset + SIZEOF_INT)
	return Vector2i(x, y)
