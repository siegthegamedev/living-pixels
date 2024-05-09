extends Node

@export var elements: Array[Element]


func _ready() -> void:
	test()
	return
	var byte_array := Packing.encode_objects(elements)
	var decoded_elements: Array[Element] = []
	decoded_elements.assign(Packing.decode_objects(byte_array, Element, elements.size()))
	
	for i in elements.size():
		print("Element " + str(i))
		print("Original data:")
		print(elements[i].id)
		print(elements[i].updated)
		print(elements[i].density)
		print(elements[i].flamability)
		print("Decoded data:")
		print(decoded_elements[i].id)
		print(decoded_elements[i].updated)
		print(decoded_elements[i].density)
		print(decoded_elements[i].flamability)
		print()


func test() -> void:
	var params := SimulationParams.new()
	params.selected_element.id = 10
	var packer := Packer.new(SimulationParams)
	
	print(params.encode())
	print(packer.encode(params))
	assert(params.encode() == packer.encode(params))
	
	var decoded_params: SimulationParams = packer.decode(packer.encode(params))
	print(decoded_params.selected_element.id)
	
	#var begin1 := Time.get_unix_time_from_system()
	#for i in 1e6:
		#params.encode()
	#var begin2 := Time.get_unix_time_from_system()
	#for i in 1e6:
		#packer.encode(params)
	#var end2 := Time.get_unix_time_from_system()
	#
	#print("encode took: " + str(begin2 - begin1))
	#print("packer took: " + str(end2 - begin2))
