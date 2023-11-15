@tool
extends TextureRect

var label: Label
var editor_interface: EditorInterface


func _ready() -> void:
	label = Label.new()
	add_child(label)
	label.position.x = size.x + 36


func _process(delta: float) -> void:
	if not editor_interface:
		editor_interface = get_parent().editor_interface
		return
	
	var data: Dictionary = {
		texture_size = texture.get_size(),
		rect_size = size,
		min_rect_size = get_minimum_size(),
		editor_scale = editor_interface.get_editor_scale(),
		visible_size = size / editor_interface.get_editor_scale(),
		viewport_size = get_global_rect().size,
	}
	label.text = ""
	for key in data.keys():
		if not label.text.is_empty():
			label.text += " | "
		label.text += "%s: %s" % [key, data[key]]
