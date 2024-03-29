class_name Element
extends Resource

@export var id: int
@export_range(0, 100, 0.01) var density: float
@export_range(0, 1, 0.01) var flamability: float


func encode() -> PackedByteArray:
	var packed_array := PackedByteArray()
	
	Packing.encode_int(packed_array, id)
	Packing.encode_floats(packed_array, [density, flamability])
	
	return Packing.pad_byte_array(packed_array)


static func decode(packed_array: PackedByteArray) -> Element:
	var decoded_id := Packing.decode_int(packed_array, 0)
	var decoded_density := Packing.decode_float(packed_array, 4)
	var decoded_flamability := Packing.decode_float(packed_array, 12)
	
	var decoded_element := Element.new()
	decoded_element.id = decoded_id
	decoded_element.density = decoded_density
	decoded_element.flamability = decoded_flamability
	return decoded_element
