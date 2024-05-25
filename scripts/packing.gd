class_name Packing
extends Object

const SIZEOF_INT: int = 4
const SIZEOF_FLOAT: int = 4
const SIZEOF_BOOL: int = 4
const SIZEOF_VECTOR2: int = 2 * SIZEOF_FLOAT
const SIZEOF_VECTOR2I: int = 2 * SIZEOF_INT
const SIZEOF_COLOR: int = 4 * SIZEOF_FLOAT


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
			TYPE_COLOR:
				size += SIZEOF_COLOR
			TYPE_OBJECT:
				var object_class_name: String = property["class_name"]
				var class_data := ProjectSettings.get_global_class_list().filter(func(data): return data["class"] == object_class_name)
				
				var script: GDScript
				if class_data.size() == 0: script = ClassDB.instantiate(object_class_name).get_script()
				else: script = load(class_data[0]["path"])
				size += Packing.sizeof_object(script)
	return size


static func get_property_names_array(type: GDScript) -> Array[String]:
	var property_names: Array[String] = []
	for property in type.get_script_property_list():
		var property_type: int = property["type"]
		var property_usage: int = property["usage"]
		if not (property_usage & PROPERTY_USAGE_SCRIPT_VARIABLE): continue
		if not (property_usage & PROPERTY_USAGE_EDITOR): continue
		match property_type:
			TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_COLOR:
				property_names.append(property["name"])
			TYPE_OBJECT:
				var object_class_name: String = property["class_name"]
				var class_data := ProjectSettings.get_global_class_list().filter(func(data): return data["class"] == object_class_name)
				
				var script: GDScript
				if class_data.size() == 0: script = ClassDB.instantiate(object_class_name).get_script()
				else: script = load(class_data[0]["path"])
				for object_property_name: String in get_property_names_array(script):
					property_names.append(property["name"] + "." + object_property_name)
	return property_names


static func get_property_sizes_array(type: GDScript) -> Array[int]:
	var sizes: Array[int] = []
	for property in type.get_script_property_list():
		var property_type: int = property["type"]
		var property_usage: int = property["usage"]
		if not (property_usage & PROPERTY_USAGE_SCRIPT_VARIABLE): continue
		if not (property_usage & PROPERTY_USAGE_EDITOR): continue
		match property_type:
			TYPE_BOOL:
				sizes.append(SIZEOF_BOOL)
			TYPE_INT:
				sizes.append(SIZEOF_INT)
			TYPE_FLOAT:
				sizes.append(SIZEOF_FLOAT)
			TYPE_VECTOR2:
				sizes.append(SIZEOF_VECTOR2)
			TYPE_VECTOR2I:
				sizes.append(SIZEOF_VECTOR2I)
			TYPE_COLOR:
				sizes.append(SIZEOF_COLOR)
			TYPE_OBJECT:
				var object_class_name: String = property["class_name"]
				var class_data := ProjectSettings.get_global_class_list().filter(func(data): return data["class"] == object_class_name)
				
				var script: GDScript
				if class_data.size() == 0: script = ClassDB.instantiate(object_class_name).get_script()
				else: script = load(class_data[0]["path"])
				sizes.append_array(get_property_sizes_array(script))
	return sizes


static func get_function_names(type: GDScript, encode: bool) -> Array[String]:
	var function_type: String = "encode" if encode else "decode"
	var function_names: Array[String] = []
	for property in type.get_script_property_list():
		var property_type: int = property["type"]
		var property_usage: int = property["usage"]
		if not (property_usage & PROPERTY_USAGE_SCRIPT_VARIABLE): continue
		if not (property_usage & PROPERTY_USAGE_EDITOR): continue
		match property_type:
			TYPE_BOOL:
				function_names.append("Packing." + function_type + "_bool")
			TYPE_INT:
				function_names.append("Packing." + function_type + "_int")
			TYPE_FLOAT:
				function_names.append("Packing." + function_type + "_float")
			TYPE_VECTOR2:
				function_names.append("Packing." + function_type + "_vector2")
			TYPE_VECTOR2I:
				function_names.append("Packing." + function_type + "_vector2i")
			TYPE_COLOR:
				function_names.append("Packing." + function_type + "_color")
			TYPE_OBJECT:
				var object_class_name: String = property["class_name"]
				var class_data := ProjectSettings.get_global_class_list().filter(func(data): return data["class"] == object_class_name)
				
				var script: GDScript
				if class_data.size() == 0: script = ClassDB.instantiate(object_class_name).get_script()
				else: script = load(class_data[0]["path"])
				function_names.append_array(Packing.get_function_names(script, encode))
	return function_names


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
			TYPE_COLOR:
				encode_color(packed_array, object[property_name])
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
			TYPE_COLOR:
				decoded_object[property_name] = decode_color(packed_array, byte_offset)
				byte_offset += SIZEOF_COLOR
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


static func encode_color(packed_array: PackedByteArray, value: Color) -> void:
	packed_array.append_array(PackedFloat32Array([value.r, value.g, value.b, value.a]).to_byte_array())


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


static func decode_color(packed_array: PackedByteArray, byte_offset: int) -> Color:
	var r := packed_array.decode_float(byte_offset)
	var g := packed_array.decode_float(byte_offset + 1 * SIZEOF_FLOAT)
	var b := packed_array.decode_float(byte_offset + 2 * SIZEOF_FLOAT)
	var a := packed_array.decode_float(byte_offset + 3 * SIZEOF_FLOAT)
	return Color(r, g, b, a)
