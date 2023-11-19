class_name jpSettings
extends RefCounted

enum {
	GMT_THEME_PRESET,
#	DIALOGUE_TESTER_SCENE_PATH,
#	DIALOGUE_TESTER_RESOURCE_PATH,
	MAX_SETTINGS,
}

const _DATA = {
	GMT_THEME_PRESET: {
		name = "gamemaster/theme/preset",
		type = TYPE_STRING_NAME,
		hint = PROPERTY_HINT_ENUM_SUGGESTION,
		hint_string = jpGMT.PRESETS_HINT_STRING,
		value = jpGMT.PRESETS.DEFAULT,
	},
#	DIALOGUE_TESTER_SCENE_PATH: {
#		name = "gamemaster/dialogue/tester/scene_path",
#		type = TYPE_STRING,
#		hint = PROPERTY_HINT_FILE,
#		hint_string = "*.tscn,*.scn",
#		value = "res://addons/jp.gamemaster/editor/dialogue/jpDialogueTester.tscn",
#	},
#	DIALOGUE_TESTER_RESOURCE_PATH: {
#		name = "gamemaster/dialogue/tester/resource_path",
#		type = TYPE_STRING,
#		hint = PROPERTY_HINT_FILE,
#		hint_string = "*.tres,*.res",
#		value = "",
#	},
}


static func get_setting(setting: int) -> Variant:
	if setting >= MAX_SETTINGS:
		return
	var setting_name: String = _get_setting_name(setting)
	if ProjectSettings.has_setting(setting_name):
		return ProjectSettings.get_setting(setting_name)
	# if a property has initial value and is not overriden,
	# it's read as null in editor, so we return it's default value.
	return _get_setting_default_value(setting)


static func get_resource(setting: int) -> Resource:
	var resource_path : String = get_setting(setting)
	if not ResourceLoader.exists(resource_path):
		return null
	return ResourceLoader.load(resource_path)


static func set_setting(setting: int, value: Variant):
	if setting >= MAX_SETTINGS:
		return
	var setting_name: String = _get_setting_name(setting)
	ProjectSettings.set_setting(setting_name, value)
	ProjectSettings.save()


static func add_all_to_project(force_default: bool = false) -> void:
	for idx in range(MAX_SETTINGS):
		var setting_name: String = _get_setting_name(idx)
		var setting_default_value: Variant = _get_setting_default_value(idx)
		var should_set_default: bool = (
			force_default
			or not ProjectSettings.has_setting(setting_name)
		)
		if should_set_default:
			ProjectSettings.set_setting(setting_name, setting_default_value)
		ProjectSettings.add_property_info(_get_setting_info(idx))
		ProjectSettings.set_initial_value(setting_name, setting_default_value)
	ProjectSettings.save()


static func remove_all_from_project() -> void:
	for idx in range(MAX_SETTINGS):
		if _DATA.has(idx) and ProjectSettings.has_setting(_DATA[idx].name):
			ProjectSettings.clear(_DATA[idx].name)
	ProjectSettings.save()


static func _get_setting_info(setting: int) -> Dictionary:
	return _DATA.get(setting, {})

static func _get_setting_name(setting: int) -> String:
	return _get_setting_info(setting).get("name", "")

static func _get_setting_default_value(setting: int) -> Variant:
	return _get_setting_info(setting).get("value", null)
