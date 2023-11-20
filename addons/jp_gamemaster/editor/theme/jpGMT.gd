class_name jpGMT
extends RefCounted
## GameMaster Theming static helper.


enum ResourceType {
	STYLE_BOX,
	LABEL_SETTINGS,
	JPMETRIC,
	JPCOLOR,
}

const CONTROL_TYPES = {
	INVALID = &"",
	PANEL = &"PANEL",
	BUTTON = &"BUTTON",
	BUTTON_LABEL = &"BUTTON_LABEL",
	BUTTON_AUTO_MODULATE = &"BUTTON_AUTO_MODULATE",
	BOX_CONTAINER = &"BOX_CONTAINER",
	MARGIN_CONTAINER = &"MARGIN_CONTAINER",
}

const PRESETS = {
	DEFAULT = &"DEFAULT",
	DARK = &"DARK",
	GODOT = &"GODOT",
}

const PRESETS_HINT_STRING = "DEFAULT,DARK,GODOT"

const OVERRIDE_DATA: Dictionary = {
	CONTROL_TYPES.PANEL: {
		^"theme_override_styles/panel": ResourceType.STYLE_BOX,
	},
	CONTROL_TYPES.BUTTON: {
		^"theme_override_styles/normal": ResourceType.STYLE_BOX,
		^"theme_override_styles/hover": ResourceType.STYLE_BOX,
		^"theme_override_styles/pressed": ResourceType.STYLE_BOX,
		^"theme_override_styles/disabled": ResourceType.STYLE_BOX,
		^"theme_override_styles/focus": ResourceType.STYLE_BOX,
		^"custom_minimum_size:x": ResourceType.JPMETRIC,
		^"custom_minimum_size:y": ResourceType.JPMETRIC,
	},
	CONTROL_TYPES.BUTTON_LABEL: {
		^"label_normal": ResourceType.LABEL_SETTINGS,
		^"label_pressed": ResourceType.LABEL_SETTINGS,
		^"label_hover": ResourceType.LABEL_SETTINGS,
		^"label_disabled": ResourceType.LABEL_SETTINGS,
		^"label_hover_pressed": ResourceType.LABEL_SETTINGS,
		^"custom_minimum_size:x": ResourceType.JPMETRIC,
		^"custom_minimum_size:y": ResourceType.JPMETRIC,
	},
	CONTROL_TYPES.BUTTON_AUTO_MODULATE: {
		^"modulate_normal": ResourceType.JPCOLOR,
		^"modulate_pressed": ResourceType.JPCOLOR,
		^"modulate_hover": ResourceType.JPCOLOR,
		^"modulate_disabled": ResourceType.JPCOLOR,
		^"modulate_hover_pressed": ResourceType.JPCOLOR,
		^"custom_minimum_size:x": ResourceType.JPMETRIC,
		^"custom_minimum_size:y": ResourceType.JPMETRIC,
	},
	CONTROL_TYPES.BOX_CONTAINER: {
		^"theme_override_constants/separation": ResourceType.JPMETRIC,
		^"custom_minimum_size:x": ResourceType.JPMETRIC,
		^"custom_minimum_size:y": ResourceType.JPMETRIC,
	},
	CONTROL_TYPES.MARGIN_CONTAINER: {
		^"theme_override_constants/margin_left": ResourceType.JPMETRIC,
		^"theme_override_constants/margin_top": ResourceType.JPMETRIC,
		^"theme_override_constants/margin_right": ResourceType.JPMETRIC,
		^"theme_override_constants/margin_bottom": ResourceType.JPMETRIC,
		^"custom_minimum_size:x": ResourceType.JPMETRIC,
		^"custom_minimum_size:y": ResourceType.JPMETRIC,
	}
}

const RESOURCE_CLASSES = {
	ResourceType.STYLE_BOX: [ &"StyleBox" ],
	ResourceType.LABEL_SETTINGS: [ &"LabelSettings" ],
	ResourceType.JPMETRIC: [ &"jpMetric" ],
	ResourceType.JPCOLOR: [ &"jpColor" ],
}

const DEFAULT_VALUES = {
	^"modulate_normal": Color.WHITE,
	^"modulate_pressed": Color.WHITE,
	^"modulate_hover": Color.WHITE,
	^"modulate_disabled": Color.WHITE,
	^"modulate_hover_pressed": Color.WHITE,
	^"theme_override_constants/separation": 4,
	^"theme_override_constants/margin_left": 0,
	^"theme_override_constants/margin_top": 0,
	^"theme_override_constants/margin_right": 0,
	^"theme_override_constants/margin_bottom": 0,
	^"custom_minimum_size:x": 0.0,
	^"custom_minimum_size:y": 0.0,
}

const META_PROPERTY = &"_gmt_properties"
const META_CONTROL_TYPE = &"_gmt_control_type"
const META_PRESET = &"_gmt_preset"


static var _editor_interface: EditorInterface
static var _pre_save_data: Dictionary


static func on_notification(control: Control, what: int) -> void:
	match what:
		Node.NOTIFICATION_READY:
			set_preset(control, get_preset(control))
		Node.NOTIFICATION_EDITOR_PRE_SAVE:
			_clean_control_pre_saving(control)
		Node.NOTIFICATION_EDITOR_POST_SAVE:
			_reset_control_post_saving(control)


static func set_control_type(
		control: Control,
		control_type: StringName
) -> void:
	control.set_meta(META_CONTROL_TYPE, control_type)


static func get_control_type(control: Control) -> StringName:
	return control.get_meta(META_CONTROL_TYPE, CONTROL_TYPES.INVALID)


static func set_property(
		control: Control,
		property: NodePath,
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
		property: NodePath,
		preset: StringName,
		default_value: Variant = null
) -> Variant:
	var data: Dictionary = control.get_meta(META_PROPERTY, {})
	var data_key: String = _get_data_key(property, preset)
	return data.get(data_key, default_value)


static func set_preset(control: Control, preset: StringName = &"") -> void:
	if preset.is_empty():
		preset = jpSettings.get_setting(jpSettings.GMT_THEME_PRESET)
	
	var control_type: StringName = get_control_type(control)
	var control_preset: StringName = get_preset(control)
	if control_type != CONTROL_TYPES.INVALID:
		var data: Dictionary = control.get_meta(META_PROPERTY, {})
		var is_default: bool = preset == PRESETS.DEFAULT
		for property in _get_properties_for(control_type):
			var data_key: StringName = _get_data_key(property, preset)
			if data.has(data_key):
				_set_control_value(control, property, data, data_key)
				continue
			
			var default_key: StringName = _get_data_key(property, PRESETS.DEFAULT)
			if data.has(default_key):
				_set_control_value(control, property, data, default_key)
		
		var owner: Node = control.owner if control.owner else control
		owner.set_meta(META_PRESET, preset)
	
	for child in control.get_children():
		if child is Control:
			set_preset(child, preset)


static func get_preset(control: Control) -> StringName:
	var owner: Node = control.owner if control.owner else control
	var preset = owner.get_meta(META_PRESET, PRESETS.DEFAULT)
	return preset


static func get_classes(resource_type: ResourceType) -> Array[StringName]:
	var classes: Array[StringName]
	classes.assign(RESOURCE_CLASSES.get(resource_type, []))
	return classes


static func _clean_control_pre_saving(control: Control) -> void:
	var control_id: int = control.get_instance_id()
	if typeof(_pre_save_data) == TYPE_NIL:
		_pre_save_data = {}
	
	var control_type: StringName = get_control_type(control)
	if control_type != CONTROL_TYPES.INVALID:
		if not _pre_save_data.has(control_id):
			_pre_save_data[control_id] = {}
			for property in _get_properties_for(control_type):
				var value: Variant = control.get_indexed(property)
				_pre_save_data[control_id][property] = value
				control.set_indexed(property, DEFAULT_VALUES.get(property, null))
		
		# handle exceptions
		match control_type:
			CONTROL_TYPES.BUTTON_LABEL:
				control.label_settings = null
	
	for child in control.get_children():
		if child is Control:
			_clean_control_pre_saving(child)


static func _reset_control_post_saving(control: Control) -> void:
	var control_id: int = control.get_instance_id()
	
	if _pre_save_data.has(control_id):
		for property in _pre_save_data[control_id]:
			var value: Variant = _pre_save_data[control_id][property]
			control.set_indexed(property, value)
		_pre_save_data.erase(control_id)
	
	for child in control.get_children():
		if child is Control:
			_reset_control_post_saving(child)


static func _set_control_value(
		control: Control,
		property: NodePath,
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
				if value is jpValue:
					value = value.get_value()
	
	if not _is_node_being_edited(control):
		value = _handle_scaling(control, value)
	
	control.set_indexed(property, value)


static func _handle_scaling(control: Control, value: Variant) -> Variant:
	var editor_scale: float = _get_editor_scale()
	
	match typeof(value):
		TYPE_INT, TYPE_FLOAT:
			value = value * editor_scale
		TYPE_OBJECT:
			if value is Resource:
				value = value.duplicate()
				match value.get_class():
					&"StyleBoxFlat":
						value.anti_aliasing_size *= editor_scale
						value.border_width_bottom *= editor_scale
						value.border_width_left *= editor_scale
						value.border_width_right *= editor_scale
						value.border_width_top *= editor_scale
						value.corner_detail *= editor_scale
						value.corner_radius_bottom_left *= editor_scale
						value.corner_radius_bottom_right *= editor_scale
						value.corner_radius_top_left *= editor_scale
						value.corner_radius_top_right *= editor_scale
						value.expand_margin_bottom *= editor_scale
						value.expand_margin_left *= editor_scale
						value.expand_margin_right *= editor_scale
						value.expand_margin_top *= editor_scale
						value.shadow_offset *= editor_scale
						value.shadow_size *= editor_scale
						value.skew *= editor_scale
					&"LabelSettings":
						value.font_size *= editor_scale
						value.line_spacing *= editor_scale
						value.outline_size *= editor_scale
						value.shadow_offset *= editor_scale
						value.shadow_size *= editor_scale
	
	return value


static func _get_data_key(property: NodePath, preset: StringName) -> String:
	return "%s:%s" % [preset, property]


static func _get_properties_for(control_type: StringName) -> Array[NodePath]:
	var properties: Array[NodePath]
	if not OVERRIDE_DATA.has(control_type):
		push_error("Unknown control type: %s" % control_type)
		return properties
	properties.assign(OVERRIDE_DATA[control_type].keys())
	return properties


static func _get_editor_scale() -> float:
	if not is_instance_valid(_editor_interface):
		var editor_plugin := EditorPlugin.new()
		_editor_interface = editor_plugin.get_editor_interface()
	return _editor_interface.get_editor_scale()


static func _is_node_being_edited(node: Node) -> bool:
	var edited_scene_root: Node = node.get_tree().edited_scene_root
	var is_node_being_edited: bool = (
		edited_scene_root != null
		and (
			edited_scene_root == node
			or edited_scene_root.is_ancestor_of(node)
		)
	)
	return is_node_being_edited
