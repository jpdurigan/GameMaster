@tool
extends Control

@export var texture_rect: TextureRect
@export var label: Label

var editor_interface: EditorInterface

func _process(_delta: float) -> void:
	var data = {
		texture = texture_rect.texture.resource_path,
		texture_size = texture_rect.texture.get_size(),
		rect_size = texture_rect.size,
		editor_scale = editor_interface.get_editor_scale() if editor_interface else null
	}
	
	label.text = ""
	for key in data.keys():
		label.text += "\n%s: %s" % [key, data[key]]
