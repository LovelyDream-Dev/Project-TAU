@tool
extends Control

@export var texture:Texture
@export var displayTextureRect:TextureRect
@export_category("Caputre")
@export var vpCapture:SubViewport
@export var vpCaptureSprite:Sprite2D
@export_category("Blur")
@export_range(1.0, 50.0, 0.1) var blurStrength:float = 10.0
@export_category("Blur Horizontal")
@export var vpHorizontal:SubViewport
@export var vpHorizontalSprite:Sprite2D
@export_category("Blur Vertical")
@export var vpVertical:SubViewport
@export var vpVerticalSprite:Sprite2D

func _process(_delta: float) -> void:
	if texture:
		vpCapture.size = texture.get_size()
		vpHorizontal.size = vpCapture.size
		vpVertical.size = vpCapture.size
		
		vpCaptureSprite.centered = false
		vpCaptureSprite.texture = texture
		vpHorizontalSprite.centered = false
		vpVerticalSprite.centered = false
		
		vpHorizontalSprite.texture = vpCapture.get_texture()
		vpVerticalSprite.texture = vpHorizontal.get_texture()
		displayTextureRect.texture = vpVertical.get_texture()

	if vpHorizontalSprite:
		var mat = vpHorizontalSprite.material
		mat.set("shader_parameter/u_sigma", blurStrength)
	if vpVerticalSprite:
		var mat = vpVerticalSprite.material
		mat.set("shader_parameter/u_sigma", blurStrength)
