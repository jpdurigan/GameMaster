extends EditorInspectorPlugin

const GAMEMASTER_FOLDER_PATH = "res://addons/jp_gamemaster"
const CONTROL_EDITOR = preload("res://addons/jp_gamemaster/editor/theme/inspector_plugin/jpgmt_control_editor.tscn")


func _can_handle(object: Object) -> bool:
	var can_handle: bool = false
	if object is Control:
		var edited_scene_path: String = (
			object.owner.scene_file_path
			if object.owner
			else object.scene_file_path
		)
		can_handle = edited_scene_path.begins_with(GAMEMASTER_FOLDER_PATH)
	return can_handle


func _parse_begin(object: Object) -> void:
	if object is Control:
		var control_editor: Control = CONTROL_EDITOR.instantiate()
		control_editor.populate(object)
		add_custom_control(control_editor)
