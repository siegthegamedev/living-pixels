class_name ElementDescriptor
extends Resource

@export var id: int
@export var name: String
@export_range(0, 100, 0.01) var density: float
@export_range(0, 1, 0.01) var flamability: float
@export_color_no_alpha var color: Color
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
