class_name Simulation
extends Node

const EMPTY_ELEMENT: Element = preload("res://resources/elements/empty.tres")
const SAND_ELEMENT:  Element = preload("res://resources/elements/sand.tres")
const WATER_ELEMENT: Element = preload("res://resources/elements/water.tres")
const WOOD_ELEMENT:  Element = preload("res://resources/elements/wood.tres")
const GAS_ELEMENT:   Element = preload("res://resources/elements/gas.tres")

@export var simulation_visualizer: Sprite2D
@export var params: SimulationParams

var input_elements: Array[Element]
var output_elements: Array[Element]

var falling_sand_compute_shader: ComputeShader
var params_compute_buffer: ComputeBuffer
var input_elements_compute_buffer: ComputeBuffer
var output_elements_compute_buffer: ComputeBuffer

var simulation_image: Image
var paused: bool = false

var output_texture_rid: RID


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
	simulation_image = Image.create(params.width, params.height, false, Image.FORMAT_RGBAH)
	
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
	
	params_compute_buffer.set_data(params)
	input_elements_compute_buffer.set_data(input_elements)
	output_elements_compute_buffer.set_data(output_elements)
	
	var output_texture_format := RDTextureFormat.new()
	output_texture_format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	output_texture_format.width = params.width
	output_texture_format.height = params.height
	output_texture_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
	output_texture_format.usage_bits += RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
	output_texture_format.usage_bits += RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	
	output_texture_rid = falling_sand_compute_shader.rendering_device.texture_create(output_texture_format, RDTextureView.new())
	
	var output_texture_uniform = RDUniform.new()
	output_texture_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	output_texture_uniform.binding = 3
	output_texture_uniform.add_id(output_texture_rid)
	
	falling_sand_compute_shader._add_uniform_to_set(output_texture_uniform, 0)


func dispatch_compute_shader() -> void:
	params.vertical_rand = randf()
	params.horizontal_rand = randf()
	
	params_compute_buffer.set_bytes(params.encode())
	falling_sand_compute_shader.setup_pipeline(ceil(params.width * params.height / 1024.), 1, 1)
	falling_sand_compute_shader.dispatch()
	falling_sand_compute_shader.sync()


func get_texture_data() -> ImageTexture:
	var output_texture_data := falling_sand_compute_shader.rendering_device.texture_get_data(output_texture_rid, 0)
	var output_image := Image.create_from_data(params.width, params.height, false, Image.FORMAT_RGBA8, output_texture_data)
	return ImageTexture.create_from_image(output_image)


func cleanup_compute_shader() -> void:
	falling_sand_compute_shader.dispose([
		params_compute_buffer,
		input_elements_compute_buffer, 
		output_elements_compute_buffer
	])


func add_element() -> void:
	params.brush_position = get_viewport().get_mouse_position() / simulation_visualizer.scale
	params.mouse_pressed = true


func update_visualization() -> void:
	simulation_visualizer.texture = get_texture_data()
	simulation_visualizer.scale = Vector2(get_window().size) / Vector2(params.width, params.height)


func get_element_color(element: Element) -> Color:
	match element.id:
		EMPTY_ELEMENT.id: return Color.TRANSPARENT
		SAND_ELEMENT.id:  return Color.BLANCHED_ALMOND
		WATER_ELEMENT.id: return Color.DARK_BLUE
		WOOD_ELEMENT.id:  return Color.SADDLE_BROWN
		GAS_ELEMENT.id:   return Color.MISTY_ROSE
	return Color(0.0, 0.0, 0.0, 0.0)
