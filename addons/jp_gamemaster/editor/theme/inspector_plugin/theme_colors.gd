@tool
extends HBoxContainer

signal color_changed(color: StringName)

var property_name: String:
	set(value):
		property_name = value
		if not is_node_ready():
			await ready
		_property_label.text = property_name

var color: StringName

@onready var _property_label: Label = %property
@onready var _colors_options: OptionButton = %options


func _ready() -> void:
	_colors_options.clear()
	var item_idx: int = 0
	var selected_idx: int = 0
	for color_name in jpGMT.COLORS:
		if color_name == color:
			selected_idx = item_idx
		_colors_options.add_item(color_name.capitalize())
		_colors_options.set_item_metadata(item_idx, color_name)
		item_idx += 1
	_colors_options.select(selected_idx)
	_colors_options.item_selected.connect(_on_colors_options_item_selected)


func _on_colors_options_item_selected(item_idx: int) -> void:
	color = _colors_options.get_item_metadata(item_idx)
	color_changed.emit(color)
