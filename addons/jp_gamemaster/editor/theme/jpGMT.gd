class_name jpGMT
extends RefCounted
## GameMaster Theming static helper.


const COLORS = {
	NONE = &"NONE",
	BACKGROUND = &"BACKGROUND",
	FOREGROUND = &"FOREGROUND",
	BLACK = &"BLACK",
	WHITE = &"WHITE",
	ACCENT = &"ACCENT",
}

const PRESET_COLORS = {
	PRESETS.DEFAULT: {
		COLORS.NONE: Color.WHITE,
		COLORS.BACKGROUND: Color("d7d5da"),
		COLORS.FOREGROUND: Color("6a5b6e"),
		COLORS.BLACK: Color("554958"),
		COLORS.WHITE: Color("f5f4f6"),
		COLORS.ACCENT: Color("0f7173"),
	},
	PRESETS.DARK: {
		COLORS.NONE: Color.WHITE,
		COLORS.BACKGROUND: Color("262128"),
		COLORS.FOREGROUND: Color("403742"),
		COLORS.BLACK: Color("6a5b6e"),
		COLORS.WHITE: Color("f5f4f6"),
		COLORS.ACCENT: Color("0f7173"),
	},
}

const CONTROL_TYPES = {
	INVALID = &"",
	PANEL = &"PANEL",
	BUTTON_AUTO_MODULATE = &"BUTTON_AUTO_MODULATE",
	TREE_EDITOR_GRID = &"TREE_EDITOR_GRID",
	TREE_EDITOR_GRID_INPUT = &"TREE_EDITOR_GRID_INPUT",
}

const PRESETS = {
	DEFAULT = &"DEFAULT",
	DARK = &"DARK",
	GODOT = &"GODOT",
}

const PRESETS_HINT_STRING = "DEFAULT,DARK,GODOT"

const META_PRESET = &"_gmt_preset"
const META_CONTROL_TYPE = &"_gmt_control_type"
const META_PROPERTY = &"_gmt_properties"
const META_APPLIED_SCALE = &"_gmt_applied_scale"


const _PROPERTY_LIST: Dictionary = {
	CONTROL_TYPES.PANEL: [
		^"self_modulate",
	],
	CONTROL_TYPES.BUTTON_AUTO_MODULATE: [
		^"modulate_normal",
		^"modulate_pressed",
		^"modulate_hover",
		^"modulate_disabled",
		^"modulate_hover_pressed",
	],
	CONTROL_TYPES.TREE_EDITOR_GRID: [
		^"grid_background_color",
		^"grid_color",
	],
	CONTROL_TYPES.TREE_EDITOR_GRID_INPUT: [
		^"focus_color",
		^"select_color"
	]
}

const _DEFAULT_VALUES = {
	^"self_modulate": Color.WHITE,
	^"grid_background_color": Color.WHITE,
	^"grid_color": Color.BLACK,
	^"focus_color": Color.WHITE,
	^"select_color": Color.WHITE,
	^"modulate_normal": Color.WHITE,
	^"modulate_pressed": Color.WHITE,
	^"modulate_hover": Color.WHITE,
	^"modulate_disabled": Color.WHITE,
	^"modulate_hover_pressed": Color.WHITE,
}

const _THEME_OVERRIDES = {
	CONSTANTS = [
		&"separation",
		&"margin_left",
		&"margin_top",
		&"margin_right",
		&"margin_bottom",
	],
	STYLES = [
		&"panel",
		&"normal",
		&"hover",
		&"pressed",
		&"disabled",
		&"focus",
	],
	FONT_SIZES = [
		&"font_size",
	],
	PROPERTIES = [
		&"custom_minimum_size",
		&"grid_size",
		&"grid_width",
		&"grid_subunit_width",
	],
}


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


static func set_preset(node: Node, preset: StringName = &"") -> void:
	if preset.is_empty():
		preset = jpSettings.get_setting(jpSettings.GMT_THEME_PRESET)
	
	if node is Control:
		var control: Control = node
		var control_type: StringName = get_control_type(control)
		var control_preset: StringName = get_preset(control)
		if control_type != CONTROL_TYPES.INVALID:
			var data: Dictionary = control.get_meta(META_PROPERTY, {})
			var is_default: bool = preset == PRESETS.DEFAULT
			for property in get_properties_for(control_type):
				var data_key: StringName = _get_data_key(property, preset)
				if data.has(data_key):
					var value: Variant = data[data_key]
					_set_control_value(control, property, value, preset)
					continue
				
				var default_key: StringName = _get_data_key(property, PRESETS.DEFAULT)
				if data.has(default_key):
					var value: Variant = data[default_key]
					_set_control_value(control, property, value, preset)
			
			var owner: Node = control.owner if control.owner else control
			owner.set_meta(META_PRESET, preset)
		
		if _is_node_being_edited(control):
			_clean_up_editing_node(control)
		else:
			_handle_scaling(control)
	
	for child in node.get_children():
		set_preset(child, preset)


static func get_preset(control: Control) -> StringName:
	var owner: Node = control.owner if control.owner else control
	var preset = owner.get_meta(META_PRESET, PRESETS.DEFAULT)
	return preset


static func _clean_control_pre_saving(node: Node) -> void:
	if typeof(_pre_save_data) == TYPE_NIL:
		_pre_save_data = {}
	
	if node is Control:
		var control: Control = node
		var control_type: StringName = get_control_type(control)
		if control_type != CONTROL_TYPES.INVALID:
			var control_id: int = control.get_instance_id()
			if not _pre_save_data.has(control_id):
				_pre_save_data[control_id] = {}
				for property in get_properties_for(control_type):
					var value: Variant = control.get_indexed(property)
					_pre_save_data[control_id][property] = value
					control.set_indexed(property, _DEFAULT_VALUES.get(property, null))
	
	for child in node.get_children():
		_clean_control_pre_saving(child)


static func _reset_control_post_saving(node: Node) -> void:
	if node is Control:
		var control: Control = node
		var control_id: int = control.get_instance_id()
		if _pre_save_data.has(control_id):
			for property in _pre_save_data[control_id]:
				var value: Variant = _pre_save_data[control_id][property]
				control.set_indexed(property, value)
			_pre_save_data.erase(control_id)
	
	for child in node.get_children():
		_reset_control_post_saving(child)


static func _set_control_value(
		control: Control,
		property: NodePath,
		value: Variant,
		preset: StringName
) -> void:
	match typeof(value):
		TYPE_STRING:
			if value.is_empty():
				return
			if value.is_absolute_path() and FileAccess.file_exists(value):
				value = load(value)
				if value is jpValue:
					value = value.get_value()
		TYPE_STRING_NAME:
			if value in COLORS.values():
				if preset == PRESETS.GODOT:
					value = _get_editor_theme_color(value)
				else:
					value = PRESET_COLORS[preset][value]
	
	control.set_indexed(property, value)


static func _clean_up_editing_node(control: Control) -> void:
	var control_type: StringName = get_control_type(control)
	var is_invalid_control_type: bool = (
		control_type == CONTROL_TYPES.INVALID
		or not CONTROL_TYPES.values().has(control_type)
	)
	if is_invalid_control_type:
		control.remove_meta(META_CONTROL_TYPE)
		control.remove_meta(META_PROPERTY)
	else:
		var data: Dictionary = control.get_meta(META_PROPERTY, {})
		var allowed_keys: Array[String] = _get_allowed_data_keys_for(control_type)
		for key in data.keys():
			if not allowed_keys.has(key):
				data.erase(key)
		control.set_meta(META_PROPERTY, data if not data.is_empty() else null)


static func _handle_scaling(control: Control) -> void:
	var editor_scale: float = _get_editor_scale()
	var applied_scale: float = control.get_meta(META_APPLIED_SCALE, 1.0)
	
	if editor_scale == applied_scale:
		return
	
	var correction_ratio: float = editor_scale / applied_scale
	for override in _THEME_OVERRIDES.CONSTANTS:
		if control.has_theme_constant_override(override):
			var value = _scale_value(control.get_theme_constant(override), correction_ratio)
			control.add_theme_constant_override(override, value)
	
	for override in _THEME_OVERRIDES.STYLES:
		if control.has_theme_stylebox_override(override):
			var value = _scale_value(control.get_theme_stylebox(override), correction_ratio)
			control.add_theme_stylebox_override(override, value)
	
	for override in _THEME_OVERRIDES.FONT_SIZES:
		if control.has_theme_font_size_override(override):
			var value = _scale_value(control.get_theme_font_size(override), correction_ratio)
			control.add_theme_font_size_override(override, value)
	
	for property in _THEME_OVERRIDES.PROPERTIES:
		if control.get(property) != null:
			var value = _scale_value(control.get(property), correction_ratio)
			control.set(property, value)
	
	control.set_meta(META_APPLIED_SCALE, editor_scale)


static func _scale_value(value: Variant, correction_ratio: float) -> Variant:
	match typeof(value):
		TYPE_INT, TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR2I:
			value *= correction_ratio
		TYPE_OBJECT:
			if value is Resource:
				value = value.duplicate()
				match value.get_class():
					&"StyleBoxFlat":
						value.anti_aliasing_size *= correction_ratio
						value.border_width_bottom *= correction_ratio
						value.border_width_left *= correction_ratio
						value.border_width_right *= correction_ratio
						value.border_width_top *= correction_ratio
						value.corner_detail *= correction_ratio
						value.corner_radius_bottom_left *= correction_ratio
						value.corner_radius_bottom_right *= correction_ratio
						value.corner_radius_top_left *= correction_ratio
						value.corner_radius_top_right *= correction_ratio
						value.expand_margin_bottom *= correction_ratio
						value.expand_margin_left *= correction_ratio
						value.expand_margin_right *= correction_ratio
						value.expand_margin_top *= correction_ratio
						value.shadow_offset *= correction_ratio
						value.shadow_size *= correction_ratio
						value.skew *= correction_ratio
					&"LabelSettings":
						value.font_size *= correction_ratio
						value.line_spacing *= correction_ratio
						value.outline_size *= correction_ratio
						value.shadow_offset *= correction_ratio
						value.shadow_size *= correction_ratio
	return value


static func _get_data_key(property: NodePath, preset: StringName) -> String:
	return "%s:%s" % [preset, property]


static func get_properties_for(control_type: StringName) -> Array[NodePath]:
	var properties: Array[NodePath]
	if not _PROPERTY_LIST.has(control_type):
		push_error("Unknown control type: %s" % control_type)
		return properties
	properties.assign(_PROPERTY_LIST[control_type])
	return properties


static func _get_allowed_data_keys_for(control_type: StringName) -> Array[String]:
	var allowed_data_keys: Array[String] = []
	var properties: Array[NodePath] = get_properties_for(control_type)
	for preset in PRESETS.values():
		for property in properties:
			allowed_data_keys.append(_get_data_key(property, preset))
	return allowed_data_keys


static func _get_editor_theme_color(color: StringName) -> Color:
	var editor_color: Color = Color.WHITE
	
	_assert_editor_interface()
	var editor_settings: EditorSettings = _editor_interface.get_editor_settings()
	var base_color: Color = editor_settings.get_setting("interface/theme/base_color")
	var accent_color: Color = editor_settings.get_setting("interface/theme/accent_color")
	var contrast: float = editor_settings.get_setting("interface/theme/contrast")
	
	match color:
		COLORS.BACKGROUND:
			editor_color = base_color.darkened(contrast)
		COLORS.FOREGROUND:
			editor_color = base_color
		COLORS.BLACK:
			editor_color = Color("010101")
		COLORS.WHITE:
			editor_color = Color("fefefe")
		COLORS.ACCENT:
			editor_color = accent_color
	
	return editor_color


static func _get_editor_scale() -> float:
	_assert_editor_interface()
	return _editor_interface.get_editor_scale()


static func _assert_editor_interface() -> void:
	if not is_instance_valid(_editor_interface):
		var editor_plugin := EditorPlugin.new()
		_editor_interface = editor_plugin.get_editor_interface()


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
