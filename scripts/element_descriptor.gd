class_name ElementDescriptor
extends Resource

@export var id: int
@export var name: String
@export_range(0, 100, 0.01) var density: float
@export_range(0, 1, 0.01) var flamability: float
@export var padding: float
@export var color: Color
@export_multiline var vertical_code: String
@export_multiline var diagonal_code: String
@export_multiline var horizontal_code: String


func get_full_code() -> String:
	var code := """
UpdateOutput update_{name}_vertical(uint x, uint y) {
	{vertical_code}
}

UpdateOutput update_{name}_diagonal(uint x, uint y) {
	{diagonal_code}
}

UpdateOutput update_{name}_horizontal(uint x, uint y) {
	{horizontal_code}
}
"""
	
	return code.format({
		"name": name.to_lower(),
		"vertical_code": vertical_code.replace("\n", "\n\t"),
		"diagonal_code": diagonal_code.replace("\n", "\n\t"),
		"horizontal_code": horizontal_code.replace("\n", "\n\t")
	})


func encode() -> PackedByteArray:
	var packed_array: PackedByteArray = []
	Packing.encode_int(packed_array, id)
	Packing.encode_float(packed_array, density)
	Packing.encode_float(packed_array, flamability)
	Packing.encode_float(packed_array, padding)
	Packing.encode_color(packed_array, color)
	return packed_array


static func decode(data: PackedByteArray) -> ElementDescriptor:
	var _id := Packing.decode_int(data, 0)
	var _density := Packing.decode_float(data, Packing.SIZEOF_INT)
	var _flamability := Packing.decode_float(data, Packing.SIZEOF_INT + Packing.SIZEOF_FLOAT)
	# there's some padding here
	var _color := Packing.decode_color(data, Packing.SIZEOF_INT + 3 * Packing.SIZEOF_FLOAT)
	
	var element_descriptor := ElementDescriptor.new()
	element_descriptor.id = _id
	element_descriptor.density = _density
	element_descriptor.flamability = _flamability
	element_descriptor.color = _color
	return element_descriptor


static func encode_array(array: Array[ElementDescriptor]) -> PackedByteArray:
	var packed_array := PackedByteArray()
	for element: ElementDescriptor in array:
		packed_array.append_array(element.encode())
	return packed_array
