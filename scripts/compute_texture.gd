class_name ComputeTexture
extends Object

var rendering_device: RenderingDevice
var format: RDTextureFormat
var texture: RID
var uniform: RDUniform


func _init(compute_shader: ComputeShader, binding_index: int, texture_format: RDTextureFormat, data: PackedByteArray = []) -> void:
	rendering_device = compute_shader.rendering_device
	format = texture_format
	
	texture = rendering_device.texture_create(format, RDTextureView.new(), data)
	
	uniform = RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = binding_index
	uniform.add_id(texture)


func set_data_from_image_texture(image_texture: ImageTexture) -> void:
	set_bytes(image_texture.get_image().get_data())


func set_data_from_image(image: Image) -> void:
	set_bytes(image.get_data())


func set_bytes(data: PackedByteArray) -> void:
	rendering_device.free_rid(texture)
	uniform.clear_ids()
	rendering_device.texture_create(format, RDTextureView.new(), data)


func get_data_to_image(image_format: Image.Format) -> Image:
	return Image.create_from_data(format.width, format.height, false, image_format, get_bytes())


func get_data_to_image_texture(image_format: Image.Format) -> ImageTexture:
	return ImageTexture.create_from_image(get_data_to_image(image_format))


func get_bytes() -> PackedByteArray:
	return rendering_device.texture_get_data(texture, 0)


func dispose() -> void:
	rendering_device.free_rid(texture)
