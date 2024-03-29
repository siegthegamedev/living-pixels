extends Node

@export var element: Element


func _ready() -> void:
	var byte_array := element.encode()
	var decoded_element := Element.decode(byte_array)
	
	print(decoded_element.id)
	print(decoded_element.density)
	print(decoded_element.flamability)
