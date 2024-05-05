class_name Simulation
extends Node

const EMPTY_ELEMENT: Element = preload("res://resources/elements/empty.tres")
const SAND_ELEMENT:  Element = preload("res://resources/elements/sand.tres")
const WATER_ELEMENT: Element = preload("res://resources/elements/water.tres")
const WOOD_ELEMENT:  Element = preload("res://resources/elements/wood.tres")
const GAS_ELEMENT:   Element = preload("res://resources/elements/gas.tres")

@export var simulation_visualizer: Sprite2D
@export var params: SimulationParams
@export var debug_labels: Array[Label]

var input_elements: Array[Element]
var output_elements: Array[Element]
var debug_metrics: SimulationDebugMetrics

var falling_sand_compute_shader: ComputeShader
var params_compute_buffer: ComputeBuffer
var input_elements_compute_buffer: ComputeBuffer
var output_elements_compute_buffer: ComputeBuffer
var output_texture_compute_texture: ComputeTexture
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
		print("Cleaning up compute shader")
		cleanup_compute_shader()
		await self.get_tree().create_timer(0.1).timeout
		self.get_tree().quit()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_0: params.selected_element = EMPTY_ELEMENT
			KEY_1: params.selected_element = SAND_ELEMENT
			KEY_2: params.selected_element = WATER_ELEMENT
			KEY_3: params.selected_element = WOOD_ELEMENT
			KEY_4: params.selected_element = GAS_ELEMENT


func setup_simulation() -> void:
	params.selected_element = SAND_ELEMENT
	debug_metrics = SimulationDebugMetrics.new()
	
	input_elements.resize(params.width * params.height)
	output_elements.resize(params.width * params.height)
	
	for i in params.width * params.height:
		input_elements[i] = EMPTY_ELEMENT
		output_elements[i] = EMPTY_ELEMENT


func setup_compute_shader() -> void:
	falling_sand_compute_shader = ComputeShader.from_file("res://shaders/compute/falling_sand.glsl")
	params_compute_buffer = falling_sand_compute_shader.create_compute_buffer(0, 0)
	input_elements_compute_buffer = falling_sand_compute_shader.create_compute_buffer(0, 1)
	output_elements_compute_buffer = falling_sand_compute_shader.create_compute_buffer(0, 2)
	output_texture_compute_texture = falling_sand_compute_shader.create_compute_texture(3, get_output_texture_format())
	debug_metrics_compute_buffer = falling_sand_compute_shader.create_compute_buffer(0, 4)
	
	params_compute_buffer.set_bytes(params.encode())
	input_elements_compute_buffer.set_data(input_elements)
	output_elements_compute_buffer.set_data(output_elements)
	debug_metrics_compute_buffer.set_data(debug_metrics)
	


func dispatch_compute_shader() -> void:
	params.vertical_rand = randf()
	params.horizontal_rand = randf()
	
	params_compute_buffer.update_bytes(params.encode())
	#params_compute_buffer.set_bytes(params.encode())
	
	var pipeline := falling_sand_compute_shader.rendering_device.compute_pipeline_create(falling_sand_compute_shader.shader)
	var compute_list := falling_sand_compute_shader.rendering_device.compute_list_begin()
	falling_sand_compute_shader.rendering_device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	for set_index: int in falling_sand_compute_shader.uniform_sets:
		var uniform_set := falling_sand_compute_shader.rendering_device.uniform_set_create(falling_sand_compute_shader.uniform_sets[set_index], falling_sand_compute_shader.shader, set_index)
		falling_sand_compute_shader.rendering_device.compute_list_bind_uniform_set(compute_list, uniform_set, set_index)
		falling_sand_compute_shader._uniform_sets.append(uniform_set)
	for i in 8:
		falling_sand_compute_shader.rendering_device.compute_list_set_push_constant(compute_list, PackedInt32Array([i]).to_byte_array(), 16)
		falling_sand_compute_shader.rendering_device.compute_list_dispatch(compute_list, ceil(params.width * params.height / 1024.), 1, 1)
		falling_sand_compute_shader.rendering_device.compute_list_add_barrier(compute_list)
	falling_sand_compute_shader.rendering_device.compute_list_end()
	
	falling_sand_compute_shader.rendering_device.submit()
	falling_sand_compute_shader.rendering_device.sync()
	
	#falling_sand_compute_shader.setup_pipeline(ceil(params.width * params.height / 1024.), 1, 1)
	#falling_sand_compute_shader.dispatch()
	#falling_sand_compute_shader.sync()


func cleanup_compute_shader() -> void:
	falling_sand_compute_shader.dispose(
		[params_compute_buffer, input_elements_compute_buffer, output_elements_compute_buffer],
		[output_texture_compute_texture]
	)


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
	match element.id:
		EMPTY_ELEMENT.id: return Color.TRANSPARENT
		SAND_ELEMENT.id:  return Color.BLANCHED_ALMOND
		WATER_ELEMENT.id: return Color.DARK_BLUE
		WOOD_ELEMENT.id:  return Color.SADDLE_BROWN
		GAS_ELEMENT.id:   return Color.MISTY_ROSE
	return Color(0.0, 0.0, 0.0, 0.0)


func get_output_texture_format() -> RDTextureFormat:
	var texture_format := RDTextureFormat.new()
	texture_format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	texture_format.width = params.width
	texture_format.height = params.height
	texture_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
	texture_format.usage_bits += RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
	texture_format.usage_bits += RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	return texture_format
