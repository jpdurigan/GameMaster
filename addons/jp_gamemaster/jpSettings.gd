class_name jpSettings
extends RefCounted

enum {
#	DIALOGUE_TESTER_SCENE_PATH,
#	DIALOGUE_TESTER_RESOURCE_PATH,
	MAX_SETTINGS,
}

const _DATA = {
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
	return ProjectSettings.get_setting(_DATA[setting].name)


static func get_resource(setting: int) -> Resource:
	var resource_path : String = get_setting(setting)
	if not ResourceLoader.exists(resource_path): return null
	return ResourceLoader.load(resource_path)


static func set_setting(setting: int, value: Variant):
	if setting >= MAX_SETTINGS:
		return
	ProjectSettings.set_setting(_DATA[setting].name, value)
	ProjectSettings.save()


static func add_all_to_project(force_default: bool = false) -> void:
	for idx in range(MAX_SETTINGS):
		var should_set_default := not ProjectSettings.has_setting(_DATA[idx].name) or force_default
		if _DATA.has(idx) and should_set_default:
			ProjectSettings.set_setting(_DATA[idx].name, _DATA[idx].value)
		ProjectSettings.add_property_info(_DATA[idx])
		# it seems that setting the initial value causes the property to not be
		# saved in project.godot and then not read in runtime
#		ProjectSettings.set_initial_value(_DATA[idx].name, _DATA[idx].value)
	ProjectSettings.save()


static func remove_all_from_project() -> void:
	for idx in range(MAX_SETTINGS):
		if _DATA.has(idx) and ProjectSettings.has_setting(_DATA[idx].name):
			ProjectSettings.clear(_DATA[idx].name)
	ProjectSettings.save()
