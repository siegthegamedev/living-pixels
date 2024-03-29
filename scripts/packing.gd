class_name Packing
extends Object


static func encode_int(packed_array: PackedByteArray, value: int) -> void:
	packed_array.append_array(PackedInt32Array([value]).to_byte_array())


static func encode_ints(packed_array: PackedByteArray, values: Array[int]) -> void:
	packed_array.append_array(PackedInt32Array(values).to_byte_array())


static func decode_int(packed_array: PackedByteArray, byte_offset: int) -> int:
	return packed_array.decode_s32(byte_offset);


static func encode_float(packed_array: PackedByteArray, value: float) -> void:
	packed_array.append_array(PackedFloat64Array([value]).to_byte_array())


static func encode_floats(packed_array: PackedByteArray, values: Array[float]) -> void:
	packed_array.append_array(PackedFloat64Array(values).to_byte_array())


static func decode_float(packed_array: PackedByteArray, byte_offset: int) -> float:
	return packed_array.decode_double(byte_offset)


static func pad_byte_array(arr: PackedByteArray) -> PackedByteArray:
	var copy = arr.duplicate()
	while copy.size() % 16 != 0:
		copy.append(0)
	return copy
