class_name SimulationParams
extends Resource

@export var width: int
@export var height: int
@export var vertical_rand: float
@export var horizontal_rand: float


func encode() -> PackedByteArray:
	var packed_array: PackedByteArray = []
	Packing.encode_int(packed_array, width)
	Packing.encode_int(packed_array, height)
	Packing.encode_float(packed_array, vertical_rand)
	Packing.encode_float(packed_array, horizontal_rand)
	return packed_array
