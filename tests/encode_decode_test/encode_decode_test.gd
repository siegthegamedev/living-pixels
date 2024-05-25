extends Node

func _ready() -> void:
	var element_descriptor : ElementDescriptor = load("res://resources/element_descriptors/sand.tres")
	var encoded := ElementDescriptor.encode_array([element_descriptor, element_descriptor, element_descriptor])
	var decoded := ElementDescriptor.decode(encoded)
	
	print(element_descriptor.color)
	print(decoded.color)
