@tool
extends Control

const ResourceDrop = preload("res://addons/jp_gamemaster/editor/theme/inspector_plugin/resource_drop.gd")
const ThemeColors = preload("res://addons/jp_gamemaster/editor/theme/inspector_plugin/theme_colors.gd")

@export var resource_drop_scene: PackedScene
@export var theme_colors_scene: PackedScene

var _control: Control

var _control_type: StringName = jpGMT.CONTROL_TYPES.INVALID:
	set(value):
		_control_type = value
		if _is_populated:
			_populate_contents()

var _preset: StringName = jpGMT.PRESETS.DEFAULT:
	set(value):
		_preset = value
		if _is_populated:
			_populate_contents()

var _is_populated: bool = false

@onready var _content: Control = %content
@onready var _control_options: OptionButton = %control_options
@onready var _presets: Control = %presets
@onready var _preset_options: OptionButton = %preset_options
@onready var _resources_parent: Control = %resources_parent


func populate(control: Control) -> void:
	_is_populated = false
	_control = control
	
	if not is_node_ready():
		await ready
	
	_control_type = jpGMT.get_control_type(_control)
	_preset = jpGMT.get_preset(_control)
	
	_populate_control_options()
	_control_options.item_selected.connect(_on_control_options_select)
	
	_populate_preset_options()
	_preset_options.item_selected.connect(_on_preset_options_select)
	
	_populate_contents()
	_update_size()
	
	_is_populated = true


func _populate_control_options() -> void:
	_control_options.clear()
	var item_idx: int = 0
	var selected_idx: int = 0
	for control in jpGMT.CONTROL_TYPES.keys():
		var control_type: StringName = jpGMT.CONTROL_TYPES[control]
		if control_type == _control_type:
			selected_idx = item_idx
		_control_options.add_item(control.capitalize())
		_control_options.set_item_metadata(item_idx, control_type)
		item_idx += 1
	_control_options.select(selected_idx)


func _populate_preset_options() -> void:
	_preset_options.clear()
	var item_idx: int = 0
	var selected_idx: int = 0
	for preset_name in jpGMT.PRESETS.keys():
		var preset: StringName = jpGMT.PRESETS[preset_name]
		if preset == _preset:
			selected_idx = item_idx
		_preset_options.add_item(preset.capitalize())
		_preset_options.set_item_metadata(item_idx, preset)
		item_idx += 1
	_preset_options.select(selected_idx)


func _populate_contents() -> void:
	for child in _resources_parent.get_children():
		_resources_parent.remove_child(child)
		child.queue_free()
	
	var override_data: Dictionary = jpGMT.OVERRIDE_DATA.get(_control_type, {})
	for property_name in override_data.keys():
		var resource_type: jpGMT.ResourceType = override_data[property_name]
		match resource_type:
			jpGMT.ResourceType.COLOR:
				var theme_colors: ThemeColors = theme_colors_scene.instantiate()
				theme_colors.property_name = property_name
				theme_colors.color = jpGMT.get_property(_control, property_name, _preset, jpGMT.COLORS.NONE)
				theme_colors.color_changed.connect(_on_property_value_changed.bind(property_name))
				_resources_parent.add_child(theme_colors)
			_:
				var resource_drop: ResourceDrop = resource_drop_scene.instantiate()
				resource_drop.property_name = property_name
				resource_drop.resource_path = jpGMT.get_property(_control, property_name, _preset, "")
				resource_drop.allowed_classes = jpGMT.get_classes(resource_type)
				resource_drop.resource_changed.connect(_on_property_value_changed.bind(property_name))
				_resources_parent.add_child(resource_drop)
	
	_update_size()


func _update_size() -> void:
	custom_minimum_size = _content.get_minimum_size()

func _on_control_options_select(index: int) -> void:
	_control_type = _control_options.get_item_metadata(index)
	jpGMT.set_control_type(_control, _control_type)

func _on_preset_options_select(index: int) -> void:
	_preset = _preset_options.get_item_metadata(index)
	var control_owner: Node = _control.owner if _control.owner else _control
	jpGMT.set_preset(control_owner, _preset)

func _on_property_value_changed(new_value: Variant, property: NodePath) -> void:
	jpGMT.set_property(_control, property, _preset, new_value)
	jpGMT.set_preset(_control, _preset)
