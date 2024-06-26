class_name SimulationParams
extends Resource

@export var width: int
@export var height: int
@export var brush_position: Vector2i
@export var brush_size: int
@export var mouse_pressed: bool
@export var selected_element_id: int
@export var vertical_rand: float
@export var horizontal_rand: float


func encode() -> PackedByteArray:
	var packed_array: PackedByteArray = []
	Packing.encode_int(packed_array, width)
	Packing.encode_int(packed_array, height)
	Packing.encode_vector2i(packed_array, brush_position)
	Packing.encode_int(packed_array, brush_size)
	Packing.encode_bool(packed_array, mouse_pressed)
	Packing.encode_int(packed_array, selected_element_id)
	Packing.encode_float(packed_array, vertical_rand)
	Packing.encode_float(packed_array, horizontal_rand)
	return packed_array
