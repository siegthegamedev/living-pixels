class_name SimulationParams
extends Resource

@export var width: int
@export var height: int
@export var brush_position: Vector2i
@export var mouse_pressed: bool
@export var selected_element: Element = Element.new()
@export var vertical_rand: float
@export var horizontal_rand: float
@export var stage: int


func encode() -> PackedByteArray:
	var packed_array: PackedByteArray = []
	Packing.encode_int(packed_array, width)
	Packing.encode_int(packed_array, height)
	Packing.encode_vector2i(packed_array, brush_position)
	Packing.encode_bool(packed_array, mouse_pressed)
	packed_array.append_array(selected_element.encode())
	Packing.encode_float(packed_array, vertical_rand)
	Packing.encode_float(packed_array, horizontal_rand)
	Packing.encode_int(packed_array, stage)
	return packed_array
