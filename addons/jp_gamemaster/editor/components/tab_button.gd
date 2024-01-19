@tool
extends "res://addons/jp_gamemaster/editor/components/button_auto_modulate.gd"

@export var tab_content: Control:
	set(value):
		tab_content = value
		button.disabled = not is_instance_valid(tab_content)

@export var icon_texture: Texture:
	set(value):
		icon_texture = value
		%icon.texture = icon_texture

@export var label_text: String:
	set(value):
		label_text = value
		%label.text = label_text


func _notification(what: int) -> void:
	jpGMT.on_notification(button, what)


func _ready() -> void:
	if not is_instance_valid(button):
		return
	button.disabled = not is_instance_valid(tab_content)
	button.toggled.connect(_toggled)
	super()


func _toggled(button_pressed: bool) -> void:
	if is_instance_valid(tab_content):
		tab_content.visible = button_pressed
