@tool
extends EditorPlugin

const GAMEMASTER_ICON_PATH = "res://addons/jp_gamemaster/editor/gamemaster.png"
const GAMEMASTER_EDITOR_PATH = "res://addons/jp_gamemaster/editor/GameMasterEditor.tscn"

var editor_interface: EditorInterface
var main_screen: Control


func _enable_plugin():
	pass
#	jpFileSystem.add_plugin_project_folders()
#	jpSettings.add_all_to_project(true)

func _disable_plugin():
	pass
#	jpSettings.remove_all_from_project()


func _enter_tree():
	editor_interface = get_editor_interface()
	main_screen = preload(GAMEMASTER_EDITOR_PATH).instantiate()
	editor_interface.get_editor_main_screen().add_child(main_screen)
	main_screen.hide()
#	jpFileSystem.add_plugin_project_folders()
#	jpFileSystem.editor_paths = editor_interface.get_editor_paths()
#	jpUID.load_from_cache()
#	jpSettings.add_all_to_project()
#	jpMeta.initialize()

func _has_main_screen():
	return true

func _make_visible(visible: bool):
	main_screen.visible = visible

func _get_plugin_name():
	return "GameMaster"

func _get_plugin_icon() -> Texture2D:
	return preload(GAMEMASTER_ICON_PATH)


func _edit(object) -> void:
	pass
#	if object is jpLogicTree:
#		main_screen.edit_tree(object)


func _handles(object) -> bool:
	var handles := false
	
#	if object is jpDialogue:
#		handles = true
	
	return handles


#func _apply_changes() -> void:
#	jpUID.save_to_cache()
