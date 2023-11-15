@tool
extends Label

@export var texture_rect: TextureRect

func _process(_delta: float) -> void:
	var data = {
		texture = texture_rect.texture.resource_path,
		texture_size = texture_rect.texture.get_size(),
		rect_size = texture_rect.size,
	}
	
	text = ""
	for key in data.keys():
		text += "\n%s: %s" % [key, data[key]]
