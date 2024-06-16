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


static func get_update_code(descriptors: Array[ElementDescriptor]) -> String:
	var code := """
void update_vertical(Element element, uint x, uint y) {
	element.updated = false;
	switch (element.id) { {vertical_cases}
		default: break;
	}
}

void update_diagonal(Element element, uint x, uint y) {
	if (!element.updated) {
		switch (element.id) { {diagonal_cases}
			default: break;
		}
	} else set_output_cell(element, x, y);
}

void update_horizontal(Element element, uint x, uint y) {
	if (!element.updated) {
		switch (element.id) { {horizontal_cases}
			default: break;
		}
	} else set_output_cell(element, x, y);
}

UpdateOutput test_update_vertical(Element element, uint x, uint y) {
	element.updated = false;
	switch (element.id) { {test_vertical_cases}
		default: return UpdateOutput(x, y, false);;
	}
}

UpdateOutput test_update_diagonal(Element element, uint x, uint y) {
	if (!element.updated) {
		switch (element.id) { {test_diagonal_cases}
			default: return UpdateOutput(x, y, false);
		}
	} else return UpdateOutput(x, y, true);
}

UpdateOutput test_update_horizontal(Element element, uint x, uint y) {
	if (!element.updated) {
		switch (element.id) { {test_horizontal_cases}
			default: return UpdateOutput(x, y, false);
		}
	} else return UpdateOutput(x, y, true);
}
"""
	
	var vertical_cases := ""
	var diagonal_cases := ""
	var horizontal_cases := ""
	
	for descriptor: ElementDescriptor in descriptors:
		vertical_cases += "\n\t\t" + descriptor.get_vertical_case_code()
		diagonal_cases += "\n\t\t\t" + descriptor.get_diagonal_case_code()
		horizontal_cases += "\n\t\t\t" + descriptor.get_horizontal_case_code()
	
	var test_vertical_cases := ""
	var test_diagonal_cases := ""
	var test_horizontal_cases := ""
	
	for descriptor: ElementDescriptor in descriptors:
		test_vertical_cases += "\n\t\t" + descriptor.get_test_vertical_case_code()
		test_diagonal_cases += "\n\t\t\t" + descriptor.get_test_diagonal_case_code()
		test_horizontal_cases += "\n\t\t\t" + descriptor.get_test_horizontal_case_code()
	
	return code.format({
		"vertical_cases": vertical_cases,
		"diagonal_cases": diagonal_cases,
		"horizontal_cases": horizontal_cases,
		"test_vertical_cases": test_vertical_cases,
		"test_diagonal_cases": test_diagonal_cases,
		"test_horizontal_cases": test_horizontal_cases,
	})


func get_full_code() -> String:
	var code := """
UpdateOutput update_{name}_vertical(Element element, uint x, uint y) {
	{vertical_code}
}

UpdateOutput update_{name}_diagonal(Element element, uint x, uint y) {
	{diagonal_code}
}

UpdateOutput update_{name}_horizontal(Element element, uint x, uint y) {
	{horizontal_code}
}
"""
	
	return code.format({
		"name": name.to_lower().replace(" ", "_"),
		"vertical_code": vertical_code.replace("\n", "\n\t"),
		"diagonal_code": diagonal_code.replace("\n", "\n\t"),
		"horizontal_code": horizontal_code.replace("\n", "\n\t")
	})


func get_vertical_case_code() -> String:
	return "case {id}: parse_update_output(element, update_{name}_vertical(element, x, y)); break;".format({
		"id": id,
		"name": name.to_lower().replace(" ", "_")
	})


func get_diagonal_case_code() -> String:
	return "case {id}: parse_update_output(element, update_{name}_diagonal(element, x, y)); break;".format({
		"id": id,
		"name": name.to_lower().replace(" ", "_")
	})


func get_horizontal_case_code() -> String:
	return "case {id}: parse_update_output(element, update_{name}_horizontal(element, x, y)); break;".format({
		"id": id,
		"name": name.to_lower().replace(" ", "_")
	})


func get_test_vertical_case_code() -> String:
	return "case {id}: return update_{name}_vertical(element, x, y);".format({
		"id": id,
		"name": name.to_lower().replace(" ", "_")
	})


func get_test_diagonal_case_code() -> String:
	return "case {id}: return update_{name}_diagonal(element, x, y);".format({
		"id": id,
		"name": name.to_lower().replace(" ", "_")
	})


func get_test_horizontal_case_code() -> String:
	return "case {id}: return update_{name}_horizontal(element, x, y);".format({
		"id": id,
		"name": name.to_lower().replace(" ", "_")
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
