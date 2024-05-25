class_name Simulation
extends Node

@export var element_descriptors: Array[ElementDescriptor]
@export var simulation_visualizer: Sprite2D
@export var params: SimulationParams
@export var debug_labels: Array[Label]

var debug_metrics: SimulationDebugMetrics

var falling_sand_compute_shader: ComputeShader
var params_compute_buffer: ComputeBuffer
var input_elements_compute_buffer: ComputeBuffer
var output_elements_compute_buffer: ComputeBuffer
var output_texture_compute_texture: ComputeTexture
var element_descriptors_compute_buffer: ComputeBuffer
var debug_metrics_compute_buffer: ComputeBuffer

var paused: bool = false


func _ready():
	print("Starting simulation")
	
	setup_simulation()
	setup_compute_shader()
	update_visualization()


func _process(_delta: float) -> void:
	get_window().title = "Living Pixels (FPS: " + str(Engine.get_frames_per_second()) + ")"
	
	# Add brush
	params.mouse_pressed = false
	if Input.is_action_pressed("add_element"): add_element()
	
	# Pause simulation
	if Input.is_action_just_pressed("simulation_toggle"): paused = not paused
	
	if not paused or Input.is_action_just_pressed("simulation_step"): 
		dispatch_compute_shader()
		update_visualization()
		update_debug_metrics()
	
	# Cleanup the simulation
	if Input.is_action_just_pressed("ui_cancel"):
		paused = true
		print("Cleaning up compute shader")
		cleanup_compute_shader()
		await self.get_tree().create_timer(0.1).timeout
		self.get_tree().quit()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		var selected_id: int = event.keycode - KEY_0
		if selected_id > 0 && selected_id < element_descriptors.size():
			params.selected_element_id = selected_id


func setup_simulation() -> void:
	params.selected_element_id = 1
	debug_metrics = SimulationDebugMetrics.new()


func setup_compute_shader() -> void:
	falling_sand_compute_shader = ComputeShader.new()
	falling_sand_compute_shader.add_indclude_from_file("res://shaders/compute/includes/macros.glsl")
	falling_sand_compute_shader.add_indclude_from_file("res://shaders/compute/includes/types.glsl")
	falling_sand_compute_shader.add_indclude_from_file("res://shaders/compute/includes/buffers.glsl")
	falling_sand_compute_shader.add_indclude_from_file("res://shaders/compute/includes/utils.glsl")
	falling_sand_compute_shader.add_indclude_from_file("res://shaders/compute/includes/update.glsl")
	falling_sand_compute_shader.add_include_from_string("elements", get_elements_code())
	falling_sand_compute_shader.add_stage_from_file_source("res://shaders/compute/input_stage.glsl")
	falling_sand_compute_shader.add_stage_from_file_source("res://shaders/compute/vertical_stage.glsl")
	falling_sand_compute_shader.add_stage_from_file_source("res://shaders/compute/swap_stage.glsl")
	falling_sand_compute_shader.add_stage_from_file_source("res://shaders/compute/diagonal_stage.glsl")
	falling_sand_compute_shader.add_stage_from_file_source("res://shaders/compute/swap_stage.glsl")
	falling_sand_compute_shader.add_stage_from_file_source("res://shaders/compute/horizontal_stage.glsl")
	falling_sand_compute_shader.add_stage_from_file_source("res://shaders/compute/swap_stage.glsl")
	falling_sand_compute_shader.add_stage_from_file_source("res://shaders/compute/final_stage.glsl")
	
	params_compute_buffer = falling_sand_compute_shader.create_compute_buffer(0, 0, 1, SimulationParams)
	input_elements_compute_buffer = falling_sand_compute_shader.create_compute_buffer(0, 1, params.width * params.height, Element)
	output_elements_compute_buffer = falling_sand_compute_shader.create_compute_buffer(0, 2, params.width * params.height, Element)
	output_texture_compute_texture = falling_sand_compute_shader.create_compute_texture(3, get_output_texture_format())
	element_descriptors_compute_buffer = falling_sand_compute_shader.create_compute_buffer(0, 4, element_descriptors.size(), ElementDescriptor)
	debug_metrics_compute_buffer = falling_sand_compute_shader.create_compute_buffer(0, 5, 1, SimulationDebugMetrics)
	
	params_compute_buffer.set_bytes(params.encode())
	element_descriptors_compute_buffer.set_bytes(ElementDescriptor.encode_array(element_descriptors))
	
	falling_sand_compute_shader.setup()


func dispatch_compute_shader() -> void:
	params.vertical_rand = randf()
	params.horizontal_rand = randf()
	
	params_compute_buffer.set_bytes(params.encode())
	falling_sand_compute_shader.dispatch(ceil(params.width * params.height / 1024.), 1, 1)


func cleanup_compute_shader() -> void:
	falling_sand_compute_shader.dispose()


func add_element() -> void:
	params.brush_position = get_viewport().get_mouse_position() / simulation_visualizer.scale
	params.mouse_pressed = true


func update_visualization() -> void:
	simulation_visualizer.texture = output_texture_compute_texture.get_data_to_image_texture(Image.FORMAT_RGBA8)
	simulation_visualizer.scale = Vector2(get_window().size) / Vector2(params.width, params.height)


func update_debug_metrics() -> void:
	var current_debug_metrics: SimulationDebugMetrics = Packing.decode_object(debug_metrics_compute_buffer.get_bytes(), SimulationDebugMetrics)
	debug_metrics.empty_count = max(debug_metrics.empty_count, current_debug_metrics.empty_count)
	debug_metrics.sand_count = max(debug_metrics.sand_count, current_debug_metrics.sand_count)
	debug_metrics.water_count = max(debug_metrics.water_count, current_debug_metrics.water_count)
	debug_metrics.wood_count = max(debug_metrics.wood_count, current_debug_metrics.wood_count)
	debug_metrics.gas_count = max(debug_metrics.gas_count, current_debug_metrics.gas_count)
	
	debug_labels[0].text = "Empty: %d / %d" % [debug_metrics.empty_count, current_debug_metrics.empty_count]
	debug_labels[1].text = "Sand: %d / %d" % [debug_metrics.sand_count, current_debug_metrics.sand_count]
	debug_labels[2].text = "Water: %d / %d" % [debug_metrics.water_count, current_debug_metrics.water_count]
	debug_labels[3].text = "Wood: %d / %d" % [debug_metrics.wood_count, current_debug_metrics.wood_count]
	debug_labels[4].text = "Gas: %d / %d" % [debug_metrics.gas_count, current_debug_metrics.gas_count]


func get_element_color(element: Element) -> Color:
	return element_descriptors[element.id].color


func get_output_texture_format() -> RDTextureFormat:
	var texture_format := RDTextureFormat.new()
	texture_format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	texture_format.width = params.width
	texture_format.height = params.height
	texture_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
	texture_format.usage_bits += RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
	texture_format.usage_bits += RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	return texture_format


func get_elements_code() -> String:
	var all_elements_code: String = ""
	for descriptor in element_descriptors.slice(1):
		all_elements_code += descriptor.get_full_code()
	all_elements_code += ElementDescriptor.get_update_code(element_descriptors.slice(1))
	return all_elements_code
