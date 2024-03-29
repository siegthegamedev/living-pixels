extends Node

@export var elements: Array[Element]


func _ready() -> void:
	var byte_array := PackedByteArray()
	for element in elements:
		byte_array.append_array(Packing.encode(element))
	var decoded_elements: Array[Element] = []
	decoded_elements.assign(Packing.decode_array(byte_array, Element, elements.size()))
	
	for i in elements.size():
		print("Element " + str(i))
		print("Original data:")
		print(elements[i].id)
		print(elements[i].density)
		print(elements[i].flamability)
		print("Decoded data:")
		print(decoded_elements[i].id)
		print(decoded_elements[i].density)
		print(decoded_elements[i].flamability)
		print()
