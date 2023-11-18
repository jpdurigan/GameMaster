class_name jpGMT
extends RefCounted
## GameMaster Theming static helper.


enum ResourceType {
	STYLE_BOX,
}

const CONTROL_TYPES = {
	INVALID = &"",
	MAIN_PANEL = &"MAIN_PANEL",
	MAIN_TAB_BUTTON = &"MAIN_TAB_BUTTON",
}

const PRESETS = {
	DEFAULT = &"DEFAULT",
	DARK = &"DARK",
	GODOT = &"GODOT",
}

const OVERRIDE_DATA: Dictionary = {
	CONTROL_TYPES.MAIN_PANEL: {
		&"theme_override_styles/panel": ResourceType.STYLE_BOX,
	},
}

const RESOURCE_CLASSES = {
	ResourceType.STYLE_BOX: [ &"StyleBox" ],
}

const META_PROPERTY = &"_gmt_properties"
const META_CONTROL_TYPE = &"_gmt_control_type"
const META_PRESET = &"_gmt_preset"


static func set_control_type(
		control: Control,
		control_type: StringName
) -> void:
	control.set_meta(META_CONTROL_TYPE, control_type)


static func get_control_type(control: Control) -> StringName:
	return control.get_meta(META_CONTROL_TYPE, CONTROL_TYPES.INVALID)


static func set_property(
		control: Control,
		property: StringName,
		preset: StringName,
		value: Variant
) -> void:
	var data: Dictionary = control.get_meta(META_PROPERTY, {})
	var data_key: String = _get_data_key(property, preset)
	if value:
		data[data_key] = value
	elif data.has(data_key):
		data.erase(data_key)
	control.set_meta(META_PROPERTY, data)


static func get_property(
		control: Control,
		property: StringName,
		preset: StringName,
		default_value: Variant = null
) -> Variant:
	var data: Dictionary = control.get_meta(META_PROPERTY, {})
	var data_key: String = _get_data_key(property, preset)
	return data.get(data_key, default_value)


static func set_preset(control: Control, preset: StringName) -> void:
	var control_type: StringName = get_control_type(control)
	if OVERRIDE_DATA.has(control_type):
		var data: Dictionary = control.get_meta(META_PROPERTY, {})
		var is_default: bool = preset == PRESETS.DEFAULT
		var properties: Array[StringName]
		properties.assign(OVERRIDE_DATA[control_type].keys())
		for property in properties:
			var data_key: StringName = _get_data_key(property, preset)
			if data.has(data_key):
				_set_control_value(control, property, data, data_key)
				continue
			
			var default_key: StringName = _get_data_key(property, PRESETS.DEFAULT)
			if data.has(default_key):
				_set_control_value(control, property, data, default_key)
	control.set_meta(META_PRESET, preset)


static func get_preset(control: Control) -> StringName:
	return control.get_meta(META_PRESET, PRESETS.DEFAULT)


static func get_classes(resource_type: ResourceType) -> Array[StringName]:
	var classes: Array[StringName]
	classes.assign(RESOURCE_CLASSES.get(resource_type, []))
	return classes


static func _set_control_value(
		control: Control,
		property: StringName,
		data: Dictionary,
		key: StringName
) -> void:
	var value: Variant = data[key]
	match typeof(value):
		TYPE_STRING:
			if value.is_empty():
				return
			if value.is_absolute_path() and FileAccess.file_exists(value):
				value = load(value)
	control.set(property, value)


static func _get_data_key(property: StringName, preset: StringName) -> String:
	return "%s:%s" % [preset, property]
