class_name Element
extends Resource

@export var id: int
@export var updated: bool
@export_range(0, 100, 0.01) var density: float
@export_range(0, 1, 0.01) var flamability: float


func encode() -> PackedByteArray:
	var packed_array: PackedByteArray = []
	Packing.encode_int(packed_array, id)
	Packing.encode_bool(packed_array, updated)
	Packing.encode_float(packed_array, density)
	Packing.encode_float(packed_array, flamability)
	return packed_array


func decode(packed_array: PackedByteArray, byte_offset: int) -> int:
	id = Packing.decode_int(packed_array, byte_offset); byte_offset += Packing.SIZEOF_INT
	updated = Packing.decode_bool(packed_array, byte_offset); byte_offset += Packing.SIZEOF_BOOL
	density = Packing.decode_float(packed_array, byte_offset); byte_offset += Packing.SIZEOF_FLOAT
	flamability = Packing.decode_float(packed_array, byte_offset); byte_offset += Packing.SIZEOF_FLOAT
	return byte_offset


static func encode_elements(elements: Array[Element]) -> PackedByteArray:
	var packed_array := PackedByteArray()
	for element in elements:
		packed_array.append_array(element.encode())
	return packed_array


static func decode_elements(packed_array: PackedByteArray, size: int) -> Array[Element]:
	var byte_offset: int = 0
	var elements: Array[Element] = []
	elements.resize(size)
	for i in size:
		elements[i] = Element.new()
		byte_offset = elements[i].decode(packed_array, byte_offset)
	return elements
