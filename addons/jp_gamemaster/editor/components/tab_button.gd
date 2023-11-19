@tool
extends Button

@export var tab_content: Control

@export var icon_texture: Texture:
	set(value):
		icon_texture = value
		%icon.texture = icon_texture

@export var label_text: String:
	set(value):
		label_text = value
		%label.text = label_text


func _ready() -> void:
	if not is_instance_valid(tab_content):
		disabled = true


func _toggled(button_pressed: bool) -> void:
	if is_instance_valid(tab_content):
		tab_content.visible = button_pressed
